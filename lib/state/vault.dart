import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/models.dart';

import '../l10n/l10n.dart';

/// In-memory cache of the user's groups, credentials (without secrets) and notes.
class Vault extends ChangeNotifier {
  Vault(this.api);

  final ApiClient api;

  bool loading = false;
  bool loaded = false;
  String? error;

  int? rootGroupId;
  List<Group> groups = [];
  List<CredentialSummary> credentials = [];
  List<NoteSummary> notes = [];

  /// Remote info learned from opened credentials (list endpoint doesn't return it).
  final Map<int, Remote?> _remoteById = {};

  List<Group> get credentialGroups => groups.where((g) => g.type == GroupType.credential).toList();
  List<Group> get noteGroups => groups.where((g) => g.type == GroupType.note).toList();

  Group? groupById(int? id) {
    for (final g in groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  String groupName(int? id) => groupById(id)?.name ?? tr.noGroup;

  bool isRoot(int? groupId) => groupId == null || groupId == rootGroupId || groupById(groupId) == null;

  List<CredentialSummary> credentialsIn(int? groupId) => credentials.where((c) => c.groupId == groupId).toList();

  List<CredentialSummary> get ungroupedCredentials => credentials.where((c) => isRoot(c.groupId)).toList();

  List<NoteSummary> notesIn(int? groupId) => notes.where((n) => n.groupId == groupId).toList();

  /// Knows whether a credential is a server only after it has been opened (or if server sends it).
  bool get knowsRemote => credentials.any((c) => c.remoteKnown || c.remote != null) || _remoteById.isNotEmpty;

  void clear() {
    loaded = false;
    rootGroupId = null;
    groups = [];
    credentials = [];
    notes = [];
    _remoteById.clear();
    notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        api.rootGroup(),
        api.groups(),
        api.credentials(),
        api.notes(),
      ]);
      rootGroupId = (results[0] as Group).id;
      groups = results[1] as List<Group>;
      credentials = (results[2] as List<CredentialSummary>).map(_withRemote).toList();
      notes = results[3] as List<NoteSummary>;
      loaded = true;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  CredentialSummary _withRemote(CredentialSummary c) {
    if (c.remoteKnown || c.remote != null || !_remoteById.containsKey(c.id)) return c;
    final r = _remoteById[c.id];
    return r == null ? c : c.copyWith(remote: r);
  }

  void _sortCreds() => credentials.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  void _sortNotes() => notes.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  void _sortGroups() => groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  // CREDENTIALS

  Future<Credential> fetchCredential(int id) async {
    final c = await api.credential(id);
    _remember(c);
    return c;
  }

  void _remember(Credential c) {
    _remoteById[c.id] = c.remote;
    final i = credentials.indexWhere((e) => e.id == c.id);
    final summary = c.toSummary();
    if (i >= 0) {
      credentials[i] = summary;
    } else {
      credentials.add(summary);
    }
    _sortCreds();
    notifyListeners();
  }

  Future<Credential> saveCredential(int? id, Map<String, dynamic> data) async {
    final c = id == null ? await api.createCredential(data) : await api.updateCredential(id, data);
    _remember(c);
    return c;
  }

  Future<void> toggleCredentialFavorite(Credential c) async {
    await saveCredential(c.id, {'favorite': !c.favorite});
  }

  Future<void> deleteCredential(int id) async {
    await api.deleteCredential(id);
    credentials.removeWhere((c) => c.id == id);
    _remoteById.remove(id);
    notifyListeners();
  }

  // NOTES

  Future<Note> fetchNote(int id) async {
    final n = await api.note(id);
    _rememberNote(n);
    return n;
  }

  void _rememberNote(Note n) {
    final i = notes.indexWhere((e) => e.id == n.id);
    if (i >= 0) {
      notes[i] = n.toSummary();
    } else {
      notes.add(n.toSummary());
    }
    _sortNotes();
    notifyListeners();
  }

  Future<Note> saveNote(int? id, Map<String, dynamic> data) async {
    final n = id == null ? await api.createNote(data) : await api.updateNote(id, data);
    _rememberNote(n);
    return n;
  }

  Future<void> deleteNote(int id) async {
    await api.deleteNote(id);
    notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // GROUPS

  Future<Group> saveGroup(int? id, String name, GroupType type) async {
    final g = id == null ? await api.createGroup(name, type) : await api.updateGroup(id, name: name, type: type);
    final i = groups.indexWhere((e) => e.id == g.id);
    if (i >= 0) {
      groups[i] = g;
    } else {
      groups.add(g);
    }
    _sortGroups();
    notifyListeners();
    return g;
  }

  Future<void> deleteGroup(int id) async {
    await api.deleteGroup(id);
    groups.removeWhere((g) => g.id == id);
    credentials.removeWhere((c) => c.groupId == id);
    notes.removeWhere((n) => n.groupId == id);
    notifyListeners();
  }
}
