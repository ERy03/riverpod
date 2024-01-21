import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  // TODO verify that inherited members reapply annotations
  // TODO assert all ".notifier" and ".future" implement Refreshable

  // This verifies that:
  // - All public APIs are documented
  // - public APIs have no unexported types
  // - {@template} are not duplicated
  // - all {@template} are used
  // - all {@macro} have an associated {@template}

  late final LibraryElement riverpod;
  late final _PublicAPIVisitor visitor;

  setUpAll(() async {
    const file = './example/lib/main.dart';
    final absolute = path.normalize(path.absolute(file));

    final result = await resolveFile2(path: absolute);
    result as ResolvedUnitResult;

    riverpod = result.libraryElement.importedLibraries.firstWhere(
      (e) => e.source.uri.toString() == 'package:riverpod/riverpod.dart',
    );
    visitor = _PublicAPIVisitor(riverpod);

    riverpod.accept(visitor);
    for (final publicApi in riverpod.exportNamespace.definedNames.values) {
      publicApi.accept(visitor);
    }
  });

  test('public API snapshot', () async {
    expect(riverpod.exportNamespace.definedNames.keys, [
      'StateNotifier',
      'AsyncValue',
      'AsyncData',
      'AsyncLoading',
      'AsyncError',
      // TODO remove
      'AsyncValueX',
      // TODO rename
      'ProviderBase',
      // TODO remove
      'FunctionalProvider',
      // TODO remove
      'RunNotifierBuild',
      // TODO remove
      'ClassProvider',
      // TODO remove
      'ClassProviderElement',
      'Refreshable',
      // TODO remove
      'ProviderElementBase',
      'ProviderContainer',
      'ProviderObserver',
      // TODO remove
      'CircularDependencyError',
      'Family',
      'ProviderSubscription',
      // TODO remove
      'ProviderListenableOrFamily',
      // TODO remove
      'ProviderOrFamily',
      // TODO remove
      'describeIdentity',
      // TODO remove
      'shortHash',
      'ProviderListenable',
      'Ref',
      'KeepAliveLink',
      'Override',
      // TODO remove
      'FutureModifier',
      // TODO remove
      'FutureModifierElement',
      'AsyncNotifier',
      'AsyncNotifierProvider',
      'FamilyAsyncNotifier',
      'FamilyAsyncNotifierProvider',
      'AsyncNotifierProviderFamily',
      'StreamNotifier',
      'StreamNotifierProvider',
      'FamilyStreamNotifier',
      'FamilyStreamNotifierProvider',
      'StreamNotifierProviderFamily',
      'StateController',
      // TODO remove
      'AutoDisposeStateNotifierProviderRef',
      // TODO remove
      'AutoDisposeStateNotifierProvider',
      // TODO remove
      'AutoDisposeStateNotifierProviderElement',
      // TODO remove
      'AutoDisposeStateNotifierProviderFamily',
      // TODO remove
      'StateNotifierProviderRef',
      'StateNotifierProvider',
      // TODO remove
      'StateNotifierProviderElement',
      'StateNotifierProviderFamily',
      // TODO remove
      'AutoDisposeStateProviderRef',
      // TODO remove
      'AutoDisposeStateProvider',
      // TODO remove
      'AutoDisposeStateProviderElement',
      // TODO remove
      'AutoDisposeStateProviderFamily',
      // TODO remove
      'StateProviderRef',
      'StateProvider',
      // TODO remove
      'StateProviderElement',
      'StateProviderFamily',
      'FutureProvider',
      // TODO remove
      'FutureProviderRef',
      // TODO remove
      'FutureProviderElement',
      'FutureProviderFamily',
      // TODO remove
      'alreadyInitializedError',
      // TODO remove
      'uninitializedElementError',
      // TODO remove
      'AutoDisposeNotifier',
      // TODO remove
      'AutoDisposeNotifierProviderRef',
      // TODO remove
      // TODO remove
      // TODO remove
      'AutoDisposeNotifierProvider',
      // TODO remove
      'AutoDisposeNotifierProviderElement',
      // TODO remove
      'AutoDisposeFamilyNotifier',
      // TODO remove
      'AutoDisposeFamilyNotifierProvider',
      // TODO remove
      'AutoDisposeNotifierProviderFamily',
      'Notifier',
      // TODO remove
      'NotifierProviderRef',
      'NotifierProvider',
      // TODO remove
      'NotifierProviderElement',
      'FamilyNotifier',
      'NotifierFamilyProvider',
      'NotifierProviderFamily',
      'Provider',
      // TODO remove
      'ProviderElement',
      'ProviderFamily',
      'StreamProvider',
      // TODO remove
      'StreamProviderElement',
      'StreamProviderFamily',
    ]);

    expect(visitor.undocumentedElements, isEmpty);

    expect(visitor.duplicateTemplates, isEmpty, reason: 'Duplicate templates');
    for (final template in visitor.templates) {
      expect(visitor.macros, contains(template), reason: 'Unused template');
    }
    for (final macro in visitor.macros) {
      expect(visitor.templates, contains(macro), reason: 'Missing template');
    }
  });

  test('public API does not contain unexported elements', () {
    expect(visitor.unexportedElements, isEmpty);
  });

  test('all public APIs are documented', () {
    expect(visitor.undocumentedElements, isEmpty);
  });

  test('all templates are used', () {
    expect(visitor.duplicateTemplates, isEmpty, reason: 'Duplicate templates');
    for (final template in visitor.templates) {
      expect(visitor.macros, contains(template), reason: 'Unused template');
    }
    for (final macro in visitor.macros) {
      expect(visitor.templates, contains(macro), reason: 'Missing template');
    }
  });

  // TODO test @visibleForTesting/protected/internal & co are inherited when overridden
}

class _PublicAPIVisitor extends GeneralizingElementVisitor<void> {
  _PublicAPIVisitor(this.riverpod);

  final LibraryElement riverpod;
  final unexportedElements = <String>{};
  final undocumentedElements = <String>{};

  final templates = <String>{};
  final duplicateTemplates = <String>{};
  final macros = <String>{};

  void _verifyTypeIsExported(DartType type, VariableElement element) {
    if (type is TypeParameterType) {
      _verifyTypeIsExported(type.bound, element);
      return;
    }

    if (type is FunctionType) {
      _verifyTypeIsExported(type.returnType, element);
      for (final parameter in type.parameters) {
        _verifyTypeIsExported(parameter.type, element);
      }
      return;
    }

    if (type.isCore) return;

    final key = type.element?.name ?? '';
    if (!riverpod.exportNamespace.definedNames.containsKey(key)) {
      unexportedElements.add('${element.location}#$key');
    }
  }

  void _verifyHasDocs(Element element) {
    if (element.documentationComment?.isNotEmpty != true) {
      undocumentedElements.add('${element.location}');
    }
  }

  bool _isPublicApi(Element element) {
    if (element.isPrivate) return false;
    // Is part of an @internal element
    if (element.thisOrAncestorMatching((e) => e.hasInternal) != null) {
      return false;
    }

    return true;
  }

  @override
  void visitElement(Element element) {
    super.visitElement(element);

    if (_isPublicApi(element)) {
      _verifyHasDocs(element);
      _parseTemplatesAndMacros(element);
    }
  }

  @override
  void visitClassElement(ClassElement element) {
    super.visitClassElement(element);

    // Verify that inherited members also respect public API constraints
    for (final superType in element.allSupertypes) {
      visitElement(element);
    }
  }

  @override
  void visitVariableElement(VariableElement element) {
    super.visitVariableElement(element);

    _verifyTypeIsExported(element.type, element);
  }

  void _parseTemplatesAndMacros(Element element) {
    final docs = element.documentationComment;
    if (docs == null) return;

    final regExp = RegExp(r'{@(\w+) (\S+)}', multiLine: true);
    for (final match in regExp.allMatches(docs)) {
      final type = match.group(1)!;
      final name = match.group(2)!;

      if (type == 'template') {
        if (!templates.add(name)) {
          duplicateTemplates.add(name);
        }
      } else if (type == 'macro') {
        macros.add(name);
      }
    }
  }
}

extension on DartType {
  /// If it is from the Dart SDK
  bool get isCore {
    if (this is DynamicType ||
        this is VoidType ||
        isDartAsyncFuture ||
        isDartAsyncFutureOr ||
        isDartAsyncStream ||
        isDartCoreBool ||
        isDartCoreDouble ||
        isDartCoreEnum ||
        isDartCoreFunction ||
        isDartCoreInt ||
        isDartCoreIterable ||
        isDartCoreList ||
        isDartCoreMap ||
        isDartCoreNull ||
        isDartCoreNum ||
        isDartCoreObject ||
        isDartCoreRecord ||
        isDartCoreSet ||
        isDartCoreString ||
        isDartCoreSymbol ||
        isDartCoreType) {
      return true;
    }

    final element = this.element;
    if (element == null) return false;

    return element.librarySource?.uri.toString().startsWith('dart:') ?? false;
  }
}