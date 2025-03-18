import 'package:flutter/material.dart';
import 'package:fymemos/pages/common_page.dart';
import 'package:refena_flutter/refena_flutter.dart';

sealed class LoadState<T> {
  const LoadState();

  /// Creates a successful [LoadState], completed with the specified [value].
  const factory LoadState.success(T value) = Success._;
  const factory LoadState.ok(T value) = Success._;

  /// Creates an error [LoadState], completed with the specified [error].
  const factory LoadState.error(Exception error) = ErrorState._;

  const factory LoadState.loading() = Loading._;
}

/// Subclass of Result for values
final class Success<T> extends LoadState<T> {
  const Success._(this.value);

  /// Returned value in result
  final T value;

  @override
  String toString() => 'LoadState<$T>.Success($value)';
}

/// Subclass of Result for errors
final class ErrorState<T> extends LoadState<T> {
  const ErrorState._(this.error);

  /// Returned error in result
  final Exception error;

  @override
  String toString() => 'LoadState<$T>.error($error)';
}

/// Subclass of Result for loading
final class Loading<T> extends LoadState<T> {
  const Loading._();
}

Widget buildPage<T>(LoadState<T> data, Function fct) {
  return switch (data) {
    ErrorState() => ErrorPage(error: data.error.toString()),
    Loading() => LoadingPage(),
    Success() => fct(data.value),
  };
}

Widget buildAsyncDataPage<T>(AsyncValue<T> data, Function fct) {
  return data.when(
    data: (d) => fct(d),
    loading: () => LoadingPage(),
    error: (err, stack) => ErrorPage(error: err.toString() + stack.toString()),
  );
}
