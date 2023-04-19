// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scoped_providers_should_specify_dependencies.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scopedHash() => r'bbf25968b1186d2dd63d10545364453712d491cf';

/// See also [scoped].
@ProviderFor(scoped)
final scopedProvider = AutoDisposeProvider<int>.internal(
  scoped,
  name: r'scopedProvider',
  debugGetCreateSourceHash: _riverpodIsDebugMode ? null : _$scopedHash,
  debugFamilyCallRuntimeType: null,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>[],
);

typedef ScopedRef = AutoDisposeProviderRef<int>;
String _$unimplementedScopedHash() =>
    r'5f32fc56f4157238612d62ef54038fe92b7cdfe8';

/// See also [unimplementedScoped].
@ProviderFor(unimplementedScoped)
final unimplementedScopedProvider = AutoDisposeProvider<int>.internal(
  (_) => throw UnsupportedError(
    'The provider "unimplementedScopedProvider" is expected to get overridden/scoped, '
    'but was accessed without an override.',
  ),
  name: r'unimplementedScopedProvider',
  debugGetCreateSourceHash:
      _riverpodIsDebugMode ? null : _$unimplementedScopedHash,
  debugFamilyCallRuntimeType: null,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnimplementedScopedRef = AutoDisposeProviderRef<int>;
String _$rootHash() => r'1cd85d73316aad02169ff0f5e7af5cf1423410ff';

/// See also [root].
@ProviderFor(root)
final rootProvider = AutoDisposeProvider<int>.internal(
  root,
  name: r'rootProvider',
  debugGetCreateSourceHash: _riverpodIsDebugMode ? null : _$rootHash,
  debugFamilyCallRuntimeType: null,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RootRef = AutoDisposeProviderRef<int>;
const _riverpodIsDebugMode = bool.fromEnvironment('dart.vm.product');
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
