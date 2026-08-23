part of com.auto_log_mi_nave_ota_labs.app.core.data.repositories.mock;

class MockLegalDocumentRepository implements LegalDocumentRepository {
  MockLegalDocumentRepository({List<LegalDocument>? seed})
    : _documents = <LegalDocument>[...?seed];

  final List<LegalDocument> _documents;

  Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<LegalDocument>> getByVehicle(String vehicleId) async {
    await _delay();
    return _documents
        .where((LegalDocument d) => d.vehicleId == vehicleId)
        .toList(growable: false);
  }

  @override
  Future<List<LegalDocument>> getAll() async {
    await _delay();
    return List<LegalDocument>.unmodifiable(_documents);
  }

  @override
  Future<LegalDocument> create(LegalDocument document) async {
    await _delay();
    LegalDocument withId = document.id.isEmpty
        ? document.copyWith(id: generateId())
        : document;
    _documents.add(withId);
    return withId;
  }

  @override
  Future<LegalDocument> update(LegalDocument document) async {
    await _delay();
    int index = _documents.indexWhere((LegalDocument d) => d.id == document.id);
    if (index == -1) throw StateError('Document ${document.id} not found');
    _documents[index] = document;
    return document;
  }

  @override
  Future<void> delete(String id) async {
    await _delay();
    _documents.removeWhere((LegalDocument d) => d.id == id);
  }
}
