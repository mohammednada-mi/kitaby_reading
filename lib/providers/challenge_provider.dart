import 'package:flutter/foundation.dart';
import 'package:kitaby_flutter/models/challenge.dart';
import 'package:kitaby_flutter/services/local_storage_service.dart';

class ChallengeProvider
    with
        ChangeNotifier {
  final LocalStorageService
  _storageService =
      LocalStorageService();
  List<
    Challenge
  >
  _challenges =
      [];
  bool
  _isLoading =
      false;
  String?
  _errorMessage;

  List<
    Challenge
  >
  get challenges =>
      _challenges;
  bool
  get isLoading =>
      _isLoading;
  String?
  get errorMessage =>
      _errorMessage;

  // Filtered lists for active and past challenges
  List<
    Challenge
  >
  get activeChallenges {
    final now =
        DateTime.now();
    // Ensure sorting happens after filtering
    final filtered =
        _challenges
            .where(
              (
                c,
              ) => c.endDate.isAfter(
                now,
              ),
            )
            .toList();
    filtered.sort(
      (
        a,
        b,
      ) => a.endDate.compareTo(
        b.endDate,
      ),
    ); // Sort by nearest deadline first
    return filtered;
  }

  List<
    Challenge
  >
  get pastChallenges {
    final now =
        DateTime.now();
    final filtered =
        _challenges
            .where(
              (
                c,
              ) =>
                  !c.endDate.isAfter(
                    now,
                  ),
            )
            .toList();
    filtered.sort(
      (
        a,
        b,
      ) => b.endDate.compareTo(
        a.endDate,
      ),
    ); // Sort by most recent end date first
    return filtered;
  }

  // Get the most relevant active challenge for the home screen
  Challenge?
  get currentActiveChallenge =>
      activeChallenges.isNotEmpty
          ? activeChallenges.first
          : null;

  // Helper to set loading state and notify listeners
  void
  _setLoading(
    bool
    loading,
  ) {
    _isLoading =
        loading;
    notifyListeners();
  }

  // Helper to set error message and notify listeners
  void
  _setError(
    String?
    message,
  ) {
    _errorMessage =
        message;
    notifyListeners();
  }

  // Clear error message
  void
  clearError() {
    if (_errorMessage !=
        null) {
      _setError(
        null,
      );
    }
  }

  ChallengeProvider() {
    loadChallenges();
  }

  Future<
    void
  >
  loadChallenges() async {
    _setLoading(
      true,
    );
    _setError(
      null,
    );
    try {
      _challenges =
          await _storageService.getChallenges();
      // Sorting is handled by the getters now, no need to sort here unless a default overall sort is desired
      // _sortChallenges();
    } catch (
      e
    ) {
      debugPrint(
        "Error loading challenges: $e",
      );
      _setError(
        "فشل تحميل التحديات. حاول مرة أخرى.",
      );
    } finally {
      _setLoading(
        false,
      );
    }
  }

  Future<
    void
  >
  addChallenge(
    Challenge
    challenge,
  ) async {
    _setLoading(
      true,
    );
    _setError(
      null,
    );
    try {
      await _storageService.addChallenge(
        challenge,
      );
      _challenges.add(
        challenge,
      );
      // No need to sort here, getters handle it
      notifyListeners(); // Notify after successful add
    } catch (
      e
    ) {
      debugPrint(
        "Error adding challenge: $e",
      );
      _setError(
        "فشل إضافة التحدي. حاول مرة أخرى.",
      );
      throw e;
    } finally {
      _setLoading(
        false,
      );
    }
  }

  Future<
    void
  >
  updateChallenge(
    Challenge
    updatedChallenge,
  ) async {
    _setLoading(
      true,
    );
    _setError(
      null,
    );
    try {
      await _storageService.updateChallenge(
        updatedChallenge,
      );
      final index = _challenges.indexWhere(
        (
          c,
        ) =>
            c.id ==
            updatedChallenge.id,
      );
      if (index !=
          -1) {
        _challenges[index] =
            updatedChallenge;
        // No need to sort here, getters handle it
        notifyListeners(); // Notify after successful update
      } else {
        debugPrint(
          "Attempted to update a challenge not found in the provider list: ${updatedChallenge.id}",
        );
      }
    } catch (
      e
    ) {
      debugPrint(
        "Error updating challenge: $e",
      );
      _setError(
        "فشل تحديث التحدي. حاول مرة أخرى.",
      );
      throw e;
    } finally {
      _setLoading(
        false,
      );
    }
  }

  Future<
    void
  >
  updateChallengeProgress(
    String
    challengeId,
    int
    newProgress,
  ) async {
    final index = _challenges.indexWhere(
      (
        c,
      ) =>
          c.id ==
          challengeId,
    );
    if (index !=
        -1) {
      final currentChallenge =
          _challenges[index];
      if (newProgress >=
              0 &&
          newProgress <=
              currentChallenge.goal) {
        final updatedChallenge = currentChallenge.copyWith(
          currentProgress:
              newProgress,
        );
        // Call updateChallenge which handles loading state and errors
        await updateChallenge(
          updatedChallenge,
        );
      } else {
        debugPrint(
          "Invalid progress value: $newProgress for challenge ${currentChallenge.id}",
        );
        _setError(
          "قيمة التقدم غير صالحة.",
        ); // Provide feedback
        // No re-throw, just set error
      }
    } else {
      debugPrint(
        "Challenge not found for progress update: $challengeId",
      );
    }
  }

  Future<
    void
  >
  deleteChallenge(
    String
    challengeId,
  ) async {
    // Optimistic UI update
    final index = _challenges.indexWhere(
      (
        c,
      ) =>
          c.id ==
          challengeId,
    );
    if (index ==
        -1)
      return;

    final challengeToRemove =
        _challenges[index];
    _challenges.removeAt(
      index,
    );
    notifyListeners(); // Update UI

    _setError(
      null,
    );
    try {
      await _storageService.deleteChallenge(
        challengeId,
      );
      // Success, UI already updated
    } catch (
      e
    ) {
      debugPrint(
        "Error deleting challenge from storage: $e",
      );
      _setError(
        "فشل حذف التحدي. حاول مرة أخرى.",
      );
      // Rollback
      _challenges.insert(
        index,
        challengeToRemove,
      );
      // No need to sort here, getters handle it
      notifyListeners(); // Update UI back
      throw e;
    }
    // No loading state needed for optimistic update
  }

  // Optional: Default sorting logic if needed outside getters
  // void _sortChallenges() {
  //   _challenges.sort((a, b) => a.endDate.compareTo(b.endDate));
  // }

  // Helper to get active challenge count, uses the getter
  int
  get activeChallengeCount =>
      activeChallenges.length;
}
