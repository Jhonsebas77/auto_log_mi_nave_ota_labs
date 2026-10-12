part of com.auto_log_mi_nave_ota_labs.app.ui.views;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  static const String route = '/dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Vehicle>> vehiclesAsync = ref.watch(vehiclesProvider);

    return vehiclesAsync.when(
      loading: () => const DashboardSkeleton(),
      // El error ya lo loguea VehiclesNotifier; aquí solo se ofrece
      // reintentar sin mostrar la excepción al usuario.
      error: (Object error, _) => _DashboardErrorState(
        retrying: vehiclesAsync.isLoading,
        onRetry: () => ref.invalidate(vehiclesProvider),
      ),
      data: (List<Vehicle> vehicles) {
        if (vehicles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Aún no tienes vehículos registrados.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  BlueprintPrimaryButton(
                    label: 'AGREGAR VEHÍCULO',
                    onPressed: () => CustomNavigator().push(
                      context,
                      const AddVehicleScreen(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Vehicle selected = ref.watch(selectedVehicleProvider) ?? vehicles.first;
        return _DashboardContent(vehicle: selected);
      },
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({required this.vehicle});

  final Vehicle vehicle;

  /// Vuelve a pedir lo que muestra el dashboard. Los vehículos no se
  /// refrescan: cada cambio local ya parchea [vehiclesProvider], y si esa
  /// consulta fallara el dashboard entero pasaría al estado de error.
  ///
  /// Los errores no se propagan: cada sección muestra el suyo (y los
  /// providers los loguean); aquí solo se espera a que terminen para cerrar
  /// el indicador.
  Future<void> _refresh(WidgetRef ref) async {
    String id = vehicle.id;
    await Future.wait(<Future<Object?>>[
      for (final Future<Object?> f in <Future<Object?>>[
        ref.refresh(legalDocumentsProvider(id).future),
        ref.refresh(fuelLogsProvider(id).future),
        ref.refresh(maintenanceRecordsProvider(id).future),
      ])
        f.then<Object?>((Object? v) => v, onError: (_) => null),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ver todayProvider: se recalcula al cambiar el día aunque el dashboard
    // siga montado en el IndexedStack de AppShell.
    DateTime now = ref.watch(todayProvider);
    LicensePlateRestrictionResult picoYPlaca = isVehicleRestrictedToday(
      licensePlate: vehicle.licensePlate,
      today: now,
    );
    AsyncValue<List<LegalDocument>> documentsAsync = ref.watch(
      legalDocumentsProvider(vehicle.id),
    );
    // Ver maintenanceAvailableProvider: mientras el módulo no esté
    // habilitado en Supabase la sección de vida útil no se muestra.
    bool maintenanceAvailable = ref.watch(maintenanceAvailableProvider);
    bool hasFuelLogs = ref.watch(
      fuelLogsProvider(vehicle.id).select(
        (AsyncValue<List<FuelLog>> logs) => logs.value?.isNotEmpty ?? false,
      ),
    );

    WindowSize windowSize = Breakpoints.windowSizeOf(context);
    bool wide = windowSize != WindowSize.compact;

    void openDocument(LegalDocument document) => CustomNavigator().push(
      context,
      DocumentDetailScreen(vehicleId: vehicle.id, documentId: document.id),
    );
    void registerDocument(DocumentType type) => CustomNavigator().push(
      context,
      RegisterDocumentScreen(prefilledType: type),
    );
    void goToTab(int index) =>
        ref.read(selectedTabIndexProvider.notifier).current = index;

    Widget vehicleCard = VehicleSelector(
      vehicle: vehicle,
      height: switch (windowSize) {
        WindowSize.compact => 220,
        WindowSize.medium => 320,
        WindowSize.expanded => null,
      },
      onEdit: () => CustomNavigator().push(
        context,
        EditVehicleScreen(vehicleId: vehicle.id),
      ),
    );
    Widget odometerCard = OdometerQuickUpdateCard(vehicle: vehicle);
    Widget picoYPlacaCard = LicensePlateRestrictionCard(
      result: picoYPlaca,
      licensePlate: vehicle.licensePlate,
    );

    // Con error no se usan los datos previos: un documento que no cargó no
    // es lo mismo que uno sin registrar.
    List<LegalDocument>? documents = documentsAsync.hasError
        ? null
        : documentsAsync.value;
    Widget documentsSection = documentsAsync.when(
      loading: () =>
          BlueprintShimmer(child: SkeletonBox(height: wide ? 240 : 84)),
      error: (Object error, _) => DashboardSectionError(
        message: 'No se pudieron cargar tus documentos.',
        retrying: documentsAsync.isLoading,
        onRetry: () => ref.invalidate(legalDocumentsProvider(vehicle.id)),
      ),
      data: (List<LegalDocument> documents) => wide
          ? DocumentStatusCards(
              documents: documents,
              now: now,
              onOpen: openDocument,
              onRegister: registerDocument,
            )
          : DocumentStatusRow(
              documents: documents,
              now: now,
              onOpen: openDocument,
              onRegister: registerDocument,
            ),
    );

    List<Widget> summaries = <Widget>[
      if (maintenanceAvailable)
        MaintenanceSummaryCard(
          statuses: ref.watch(lifespanProvider(vehicle.id)),
          onViewAll: () => goToTab(AppShell.maintenanceIndex),
        ),
      if (hasFuelLogs)
        FuelSummaryCard(
          metrics: ref.watch(fuelMetricsProvider(vehicle.id)),
          now: now,
          onViewAll: () => goToTab(AppShell.fuelIndex),
        ),
    ];

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: SingleChildScrollView(
        // Para que "deslizar para refrescar" funcione aunque el contenido
        // quepa en pantalla.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: wide
            ? const EdgeInsets.all(32)
            : const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Vencidos/por vencer arriba de todo: en móvil la sección de
            // documentos queda fuera de la primera pantalla.
            if (documents != null)
              DashboardAlertsBanner(
                documents: documents,
                now: now,
                onOpen: openDocument,
                padding: const EdgeInsets.only(bottom: 16),
              ),
            if (windowSize == WindowSize.expanded)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 280),
                        child: vehicleCard,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          odometerCard,
                          const SizedBox(height: 16),
                          picoYPlacaCard,
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...<Widget>[
              vehicleCard,
              const SizedBox(height: 16),
              odometerCard,
              const SizedBox(height: 16),
              picoYPlacaCard,
            ],
            const SizedBox(height: 16),
            documentsSection,
            if (summaries.isNotEmpty) ...<Widget>[
              const SizedBox(height: 16),
              if (windowSize == WindowSize.expanded && summaries.length == 2)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(child: summaries[0]),
                      const SizedBox(width: 16),
                      Expanded(child: summaries[1]),
                    ],
                  ),
                )
              else
                for (int i = 0; i < summaries.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: 16),
                  summaries[i],
                ],
            ],
          ],
        ),
      ),
    );
  }
}

/// No se pudieron cargar los vehículos. Mensaje amigable (la excepción ya
/// quedó en el log) y "Reintentar"; [retrying] deshabilita el botón
/// mientras se vuelve a consultar.
class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({required this.onRetry, required this.retrying});

  final VoidCallback onRetry;
  final bool retrying;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: BlueprintColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No pudimos cargar tu vehículo.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisa tu conexión a internet e inténtalo de nuevo.',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: retrying ? null : onRetry,
            icon: retrying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}
