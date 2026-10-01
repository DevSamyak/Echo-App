// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saavn_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$saavnFeedHash() => r'c01e63bd08749f240ae956021b9598e6a9004fa5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// One provider for every Saavn row on the Discover page.
///
///   ref.watch(saavnFeedProvider('trending'))  -> Top Hindi / Bollywood
///   ref.watch(saavnFeedProvider('punjabi'))   -> Punjabi hits
///   ref.watch(saavnFeedProvider('retro'))     -> Old classics
///
/// [section] must be a key from the server's SECTIONS map.
///
/// Copied from [saavnFeed].
@ProviderFor(saavnFeed)
const saavnFeedProvider = SaavnFeedFamily();

/// One provider for every Saavn row on the Discover page.
///
///   ref.watch(saavnFeedProvider('trending'))  -> Top Hindi / Bollywood
///   ref.watch(saavnFeedProvider('punjabi'))   -> Punjabi hits
///   ref.watch(saavnFeedProvider('retro'))     -> Old classics
///
/// [section] must be a key from the server's SECTIONS map.
///
/// Copied from [saavnFeed].
class SaavnFeedFamily extends Family<AsyncValue<List<SongModel>>> {
  /// One provider for every Saavn row on the Discover page.
  ///
  ///   ref.watch(saavnFeedProvider('trending'))  -> Top Hindi / Bollywood
  ///   ref.watch(saavnFeedProvider('punjabi'))   -> Punjabi hits
  ///   ref.watch(saavnFeedProvider('retro'))     -> Old classics
  ///
  /// [section] must be a key from the server's SECTIONS map.
  ///
  /// Copied from [saavnFeed].
  const SaavnFeedFamily();

  /// One provider for every Saavn row on the Discover page.
  ///
  ///   ref.watch(saavnFeedProvider('trending'))  -> Top Hindi / Bollywood
  ///   ref.watch(saavnFeedProvider('punjabi'))   -> Punjabi hits
  ///   ref.watch(saavnFeedProvider('retro'))     -> Old classics
  ///
  /// [section] must be a key from the server's SECTIONS map.
  ///
  /// Copied from [saavnFeed].
  SaavnFeedProvider call(
    String section,
  ) {
    return SaavnFeedProvider(
      section,
    );
  }

  @override
  SaavnFeedProvider getProviderOverride(
    covariant SaavnFeedProvider provider,
  ) {
    return call(
      provider.section,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'saavnFeedProvider';
}

/// One provider for every Saavn row on the Discover page.
///
///   ref.watch(saavnFeedProvider('trending'))  -> Top Hindi / Bollywood
///   ref.watch(saavnFeedProvider('punjabi'))   -> Punjabi hits
///   ref.watch(saavnFeedProvider('retro'))     -> Old classics
///
/// [section] must be a key from the server's SECTIONS map.
///
/// Copied from [saavnFeed].
class SaavnFeedProvider extends AutoDisposeFutureProvider<List<SongModel>> {
  /// One provider for every Saavn row on the Discover page.
  ///
  ///   ref.watch(saavnFeedProvider('trending'))  -> Top Hindi / Bollywood
  ///   ref.watch(saavnFeedProvider('punjabi'))   -> Punjabi hits
  ///   ref.watch(saavnFeedProvider('retro'))     -> Old classics
  ///
  /// [section] must be a key from the server's SECTIONS map.
  ///
  /// Copied from [saavnFeed].
  SaavnFeedProvider(
    String section,
  ) : this._internal(
          (ref) => saavnFeed(
            ref as SaavnFeedRef,
            section,
          ),
          from: saavnFeedProvider,
          name: r'saavnFeedProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$saavnFeedHash,
          dependencies: SaavnFeedFamily._dependencies,
          allTransitiveDependencies: SaavnFeedFamily._allTransitiveDependencies,
          section: section,
        );

  SaavnFeedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.section,
  }) : super.internal();

  final String section;

  @override
  Override overrideWith(
    FutureOr<List<SongModel>> Function(SaavnFeedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SaavnFeedProvider._internal(
        (ref) => create(ref as SaavnFeedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        section: section,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SongModel>> createElement() {
    return _SaavnFeedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaavnFeedProvider && other.section == section;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, section.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SaavnFeedRef on AutoDisposeFutureProviderRef<List<SongModel>> {
  /// The parameter `section` of this provider.
  String get section;
}

class _SaavnFeedProviderElement
    extends AutoDisposeFutureProviderElement<List<SongModel>>
    with SaavnFeedRef {
  _SaavnFeedProviderElement(super.provider);

  @override
  String get section => (origin as SaavnFeedProvider).section;
}

String _$saavnSearchHash() => r'ff1abc65834ecc5d6d44fb40f14b24b55c3b4c1e';

/// Used by the Search tab. Auto-disposes so old searches don't pile up.
///
/// Copied from [saavnSearch].
@ProviderFor(saavnSearch)
const saavnSearchProvider = SaavnSearchFamily();

/// Used by the Search tab. Auto-disposes so old searches don't pile up.
///
/// Copied from [saavnSearch].
class SaavnSearchFamily extends Family<AsyncValue<List<SongModel>>> {
  /// Used by the Search tab. Auto-disposes so old searches don't pile up.
  ///
  /// Copied from [saavnSearch].
  const SaavnSearchFamily();

  /// Used by the Search tab. Auto-disposes so old searches don't pile up.
  ///
  /// Copied from [saavnSearch].
  SaavnSearchProvider call(
    String query,
  ) {
    return SaavnSearchProvider(
      query,
    );
  }

  @override
  SaavnSearchProvider getProviderOverride(
    covariant SaavnSearchProvider provider,
  ) {
    return call(
      provider.query,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'saavnSearchProvider';
}

/// Used by the Search tab. Auto-disposes so old searches don't pile up.
///
/// Copied from [saavnSearch].
class SaavnSearchProvider extends AutoDisposeFutureProvider<List<SongModel>> {
  /// Used by the Search tab. Auto-disposes so old searches don't pile up.
  ///
  /// Copied from [saavnSearch].
  SaavnSearchProvider(
    String query,
  ) : this._internal(
          (ref) => saavnSearch(
            ref as SaavnSearchRef,
            query,
          ),
          from: saavnSearchProvider,
          name: r'saavnSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$saavnSearchHash,
          dependencies: SaavnSearchFamily._dependencies,
          allTransitiveDependencies:
              SaavnSearchFamily._allTransitiveDependencies,
          query: query,
        );

  SaavnSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<SongModel>> Function(SaavnSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SaavnSearchProvider._internal(
        (ref) => create(ref as SaavnSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SongModel>> createElement() {
    return _SaavnSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaavnSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SaavnSearchRef on AutoDisposeFutureProviderRef<List<SongModel>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SaavnSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<SongModel>>
    with SaavnSearchRef {
  _SaavnSearchProviderElement(super.provider);

  @override
  String get query => (origin as SaavnSearchProvider).query;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
