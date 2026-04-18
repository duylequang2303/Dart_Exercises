// REMOVED: lib/features/workout/data/workout_timer_service.dart
// This file previously re-exported the presentation-layer timer service.
// Per architecture rules the data layer must not depend on presentation.
// The concrete timer implementation now lives at:
//   lib/features/workout/presentation/services/workout_timer_service.dart
//
// NOTE: The file's presence is left intentionally as an empty marker in this environment
// because the runtime cannot delete files directly (pwsh not available). Please delete
// this file locally or via CI if a full removal is required.
