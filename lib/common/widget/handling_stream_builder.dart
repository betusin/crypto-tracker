import 'package:crypto_tracker/common/model/reference_wrapper.dart';
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
    final isTNullable = null is T;

    if (isTNullable) {
      return _buildHandle<ReferenceWrapper<T?>>(
        stream: stream?.map(ReferenceWrapper.new),
        builder: (context, lastWrappedValue) => builder(context, lastWrappedValue.wrapped as T),
        initialData: initialData == null ? null : ReferenceWrapper(initialData),
      );
    }

    return _buildHandle(stream: stream, builder: builder, initialData: initialData);
  }

  Widget _buildHandle<T>({Stream<T>? stream, required WidgetBuilderWithData<T> builder, T? initialData}) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              Text('Unexpected error: ${snapshot.error} occurred. Please try again later.');
        }

        if (!snapshot.hasData) {
          return waitingForDataWidget ?? const Center(child: CircularProgressIndicator());
        }

        // ignore: null_check_on_nullable_type_parameter
        return builder(context, snapshot.data!);
      },
    );
  }
}
