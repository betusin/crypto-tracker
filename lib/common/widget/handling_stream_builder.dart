import 'package:flutter/material.dart';

typedef WidgetBuilderWithData<T> = Widget Function(BuildContext context, T data);

class HandlingStreamBuilder<T> extends StatelessWidget {
  final Stream<T>? stream;
  final WidgetBuilderWithData<T> builder;
  final WidgetBuilderWithData<Object?>? errorBuilder;
  final T? initialData;
  final Widget? waitingForDataWidget;
  final bool ignoreNullInitialData;

  const HandlingStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.initialData,
    this.waitingForDataWidget,
    this.ignoreNullInitialData = true,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              Text('Unexpected error: ${snapshot.error} occurred. Please try again later.');
        }

        final data = snapshot.data;

        if (data == null) {
          return waitingForDataWidget ?? const Center(child: CircularProgressIndicator());
        }

        return builder(context, data);
      },
    );
  }
}
