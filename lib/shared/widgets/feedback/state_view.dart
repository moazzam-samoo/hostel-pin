import 'package:flutter/material.dart';

// Named StateViewStatus (not ViewState) to avoid colliding with the
// broader, controller-facing core/enums/view_state.dart ViewState enum.
enum StateViewStatus { loading, empty, error, content }

class StateView extends StatelessWidget {
  final StateViewStatus state;
  final Widget contentBuilder;
  final Widget? emptyBuilder;
  final Widget? loadingBuilder;
  final Widget? errorBuilder;

  const StateView({
    super.key,
    required this.state,
    required this.contentBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case StateViewStatus.loading:
        return loadingBuilder ?? const Center(child: CircularProgressIndicator());
      case StateViewStatus.empty:
        return emptyBuilder ?? const SizedBox.shrink();
      case StateViewStatus.error:
        return errorBuilder ?? const Center(child: Text('An error occurred.'));
      case StateViewStatus.content:
        return contentBuilder;
    }
  }
}
