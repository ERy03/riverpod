part of '../notifier.dart';

/// {@template riverpod.notifier}
/// A class which exposes a state that can change over time.
///
/// For example, [Notifier] can be used to implement a counter by doing:
///
/// ```dart
/// final counterProvider = NotifierProvider<Counter, int>(Counter.new);
///
/// class Counter extends Notifier<int> {
///   @override
///   int build() {
///     // Inside "build", we return the initial state of the counter.
///     return 0;
///   }
///
///   void increment() {
///     state++;
///   }
/// }
/// ```
///
/// We can then listen to the counter inside widgets by doing:
///
/// ```dart
/// Consumer(
///   builder: (context, ref) {
///     return Text('count: ${ref.watch(counterProvider)}');
///   },
/// )
/// ```
///
/// And finally, we can update the counter by doing:
///
/// ```dart
/// Consumer(
///   builder: (context, ref) {
///     return ElevatedButton(
///       onTap: () => ref.read(counterProvider.notifier).increment(),
///       child: const Text('increment'),
///     );
///   },
/// )
/// ```
///
/// The state of [Notifier] is expected to be initialized synchronously.
/// For asynchronous initializations, see [AsyncNotifier].
/// {@endtemplate}
///
/// {@template riverpod.notifier_provider_modifier}
/// When using `autoDispose` or `family`, your notifier type changes.
/// Instead of extending [Notifier], you should extend either:
/// - [AutoDisposeNotifier] for `autoDispose`
/// - [FamilyNotifier] for `family`
/// - [AutoDisposeFamilyNotifier] for `autoDispose.family`
/// {@endtemplate}
abstract class Notifier<State> extends _NotifierBase<State> {
  /// {@template riverpod.notifier.build}
  /// Initialize a [Notifier].
  ///
  /// It is safe to use [Ref.watch] or [Ref.listen] inside this method.
  ///
  /// If a dependency of this [Notifier] (when using [Ref.watch]) changes,
  /// then [build] will be re-executed. On the other hand, the [Notifier]
  /// will **not** be recreated. Its instance will be preserved between
  /// executions of [build].
  ///
  /// If this method throws, reading this provider will rethrow the error.
  /// {@endtemplate}
  @visibleForOverriding
  State build();
}

final class NotifierProvider<NotifierT extends Notifier<StateT>, StateT>
    extends _NotifierProvider<NotifierT, StateT> {
  /// {@macro riverpod.notifier_provider}
  ///
  /// {@macro riverpod.notifier_provider_modifier}
  NotifierProvider(
    super._createNotifier, {
    super.name,
    super.dependencies,
    super.isAutoDispose = false,
  }) : super(
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          from: null,
          argument: null,
          debugGetCreateSourceHash: null,
          runNotifierBuildOverride: null,
        );

  NotifierProvider._autoDispose(
    super._createNotifier, {
    super.name,
    super.dependencies,
  }) : super(
          allTransitiveDependencies:
              computeAllTransitiveDependencies(dependencies),
          isAutoDispose: true,
          from: null,
          argument: null,
          debugGetCreateSourceHash: null,
          runNotifierBuildOverride: null,
        );

  /// An implementation detail of Riverpod
  @internal
  NotifierProvider.internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required super.argument,
    required super.isAutoDispose,
    required super.runNotifierBuildOverride,
  });

  /// {@macro riverpod.autoDispose}
  static const autoDispose = AutoDisposeNotifierProviderBuilder();

  /// {@macro riverpod.family}
  static const family = NotifierProviderFamilyBuilder();

  @override
  _NotifierProviderElement<NotifierT, StateT> createElement(
    ProviderContainer container,
  ) {
    return _NotifierProviderElement(this, container);
  }

  NotifierProvider<NotifierT, StateT> _copyWith({
    NotifierT Function()? create,
    RunNotifierBuild<NotifierT, StateT, Ref<StateT>>? build,
  }) {
    return NotifierProvider<NotifierT, StateT>.internal(
      create ?? _createNotifier,
      name: name,
      dependencies: dependencies,
      allTransitiveDependencies: allTransitiveDependencies,
      debugGetCreateSourceHash: debugGetCreateSourceHash,
      from: from,
      argument: argument,
      isAutoDispose: isAutoDispose,
      runNotifierBuildOverride: build ?? runNotifierBuildOverride,
    );
  }

  @internal
  @override
  NotifierProvider<NotifierT, StateT> copyWithBuild(
    RunNotifierBuild<NotifierT, StateT, Ref<StateT>>? build,
  ) {
    return _copyWith(build: build);
  }

  @internal
  @override
  NotifierProvider<NotifierT, StateT> copyWithCreate(
    NotifierT Function() create,
  ) {
    return _copyWith(create: create);
  }
}

class _NotifierProviderElement< //
        NotifierT extends _NotifierBase<StateT>,
        StateT> //
    extends ClassProviderElement< //
        NotifierT,
        StateT,
        StateT> //
{
  _NotifierProviderElement(this.provider, super.container);

  @override
  final _NotifierProvider<NotifierT, StateT> provider;

  @override
  void handleError(
    Object error,
    StackTrace stackTrace, {
    required bool didChangeDependency,
  }) {
    Zone.current.handleUncaughtError(error, stackTrace);
  }

  @override
  void handleValue(
    StateT created, {
    required bool didChangeDependency,
  }) {
    state = created;
  }
}