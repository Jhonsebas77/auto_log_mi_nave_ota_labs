part of com.auto_log_mi_nave_ota_labs.app.ui.widgets;

/// Tarjeta del único vehículo del usuario: foto (o un panel con su color
/// como respaldo), placa y acción de editar superpuestas, y nombre/año
/// sobre un degradado en la parte inferior. La app solo soporta un
/// vehículo por usuario, así que no ofrece selección entre varios.
class VehicleSelector extends StatelessWidget {
  const VehicleSelector({required this.vehicle, this.onEdit, super.key});

  final Vehicle vehicle;
  final VoidCallback? onEdit;

  String get _title =>
      (vehicle.nickname == null || vehicle.nickname!.trim().isEmpty)
      ? '${vehicle.brand} ${vehicle.model}'
      : vehicle.nickname!.trim();

  @override
  Widget build(BuildContext context) => Container(
    height: 220,
    decoration: BoxDecoration(
      border: Border.all(color: BlueprintColors.outlineVariant),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _VehicleBackground(vehicle: vehicle),
        const Positioned.fill(child: _BottomShadeOverlay()),
        Positioned(
          top: 14,
          right: 14,
          child: _PlateBadge(licensePlate: vehicle.licensePlate),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 14,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        Text(
                          '${vehicle.year}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _ColorDot(color: colorSwatchForVehicle(vehicle.color)),
                      ],
                    ),
                  ],
                ),
              ),
              if (onEdit != null) ...<Widget>[
                const SizedBox(width: 8),
                _EditButton(onTap: onEdit!),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

/// Degradado oscuro en la mitad inferior de la tarjeta para que el nombre
/// y el año del vehículo sean legibles sobre la foto o el panel de color.
class _BottomShadeOverlay extends StatelessWidget {
  const _BottomShadeOverlay();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const <double>[0, 0.55, 1],
        colors: <Color>[
          Colors.transparent,
          Colors.transparent,
          Colors.black.withValues(alpha: 0.75),
        ],
      ),
    ),
  );
}

/// Foto del vehículo si existe; si no, un panel con su color y un ícono de
/// carro como respaldo.
class _VehicleBackground extends StatelessWidget {
  const _VehicleBackground({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    String? photoUrl = vehicle.photoUrl;
    if (photoUrl != null) {
      return Image(
        image: attachmentImageProvider(photoUrl),
        fit: BoxFit.cover,
        // Fotos viejas guardadas como ruta local (antes de subir a Supabase
        // Storage) pueden ya no existir en disco — cae al mismo respaldo de
        // color/ícono en vez de crashear.
        errorBuilder: (_, __, ___) => _fallbackBackground(vehicle.color),
      );
    }
    return _fallbackBackground(vehicle.color);
  }

  Widget _fallbackBackground(String color) {
    Color swatch = colorSwatchForVehicle(color);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            swatch.withValues(alpha: 0.55),
            swatch.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.directions_car,
          size: 120,
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _PlateBadge extends StatelessWidget {
  const _PlateBadge({required this.licensePlate});

  final String licensePlate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      licensePlate,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),
  );
}

/// Círculo pequeño con el color del vehículo, junto al año.
class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
    ),
  );
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black.withValues(alpha: 0.45),
    shape: const CircleBorder(),
    child: IconButton(
      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
      tooltip: 'Editar vehículo',
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: EdgeInsets.zero,
    ),
  );
}
