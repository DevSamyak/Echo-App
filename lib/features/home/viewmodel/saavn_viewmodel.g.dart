// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saavn_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$saavnFeedHash() => r'f689d2b467039f98ed467a8c99207d8f47ae07ae';

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
///   ref.watch(saavnFeedProvider('trending', page: 1))  -> Top Hindi / Bollywood
///
/// [section] must be a key from the server's SECTIONS map.
///
/// Copied from [saavnFeed].
@ProviderFor(saavnFeed)
const saavnFeedProvider = SaavnFeedFamily();

/// One provider for every Saavn row on the Discover page.
///
///   ref.watch(saavnFeedProvider('trending', page: 1))  -> Top Hindi / Bollywood
///
/// [section] must be a key from the server's SECTIONS map.
///
/// Copied from [saavnFeed].
class SaavnFeedFamily extends Family<AsyncValue<List<SongModel>>> {
  /// One provider for every Saavn row on the Discover page.
  ///
  ///   ref.watch(saavnFeedProvider('trending', page: 1))  -> Top Hindi / Bollywood
  ///
  /// [section] must be a key from the server's SECTIONS map.
  ///
  /// Copied from [saavnFeed].
  const SaavnFeedFamily();

  /// One provider for every Saavn row on the Discover page.
  ///
  ///   ref.watch(saavnFeedProvider('trending', page: 1))  -> Top Hindi / Bollywood
  ///
  /// [section] must be a key from the server's SECTIONS map.
  ///
  /// Copied from [saavnFeed].
  SaavnFeedProvider call(
    String section, {
    int page = 1,
  }) {
    return SaavnFeedProvider(
      section,
      page: page,
    );
  }

  @override
  SaavnFeedProvider getProviderOverride(
    covariant SaavnFeedProvider provider,
  ) {
    return call(
      provider.section,
      page: provider.page,
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
///   ref.watch(saavnFeedProvider('trending', page: 1))  -> Top Hindi / Bollywood
///
/// [section] must be a key from the server's SECTIONS map.
///
/// Copied from [saavnFeed].
class SaavnFeedProvider extends AutoDisposeFutureProvider<List<SongModel>> {
  /// One provider for every Saavn row on the Discover page.
  ///
  ///   ref.watch(saavnFeedProvider('trending', page: 1))  -> Top Hindi / Bollywood
  ///
  /// [section] must be a key from the server's SECTIONS map.
  ///
  /// Copied from [saavnFeed].
  SaavnFeedProvider(
    String section, {
    int page = 1,
  }) : this._internal(
          (ref) => saavnFeed(
            ref as SaavnFeedRef,
            section,
            page: page,
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
          page: page,
        );

  SaavnFeedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.section,
    required this.page,
  }) : super.internal();

  final String section;
  final int page;

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
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SongModel>> createElement() {
    return _SaavnFeedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaavnFeedProvider &&
        other.section == section &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, section.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SaavnFeedRef on AutoDisposeFutureProviderRef<List<SongModel>> {
  /// The parameter `section` of this provider.
  String get section;

  /// The parameter `page` of this provider.
  int get page;
}

class _SaavnFeedProviderElement
    extends AutoDisposeFutureProviderElement<List<SongModel>>
    with SaavnFeedRef {
  _SaavnFeedProviderElement(super.provider);

  @override
  String get section => (origin as SaavnFeedProvider).section;
  @override
  int get page => (origin as SaavnFeedProvider).page;
}

String _$saavnSearchHash() => r'80ba402f9998903a44a33830f36907279d7be141';

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
    String query, {
    int page = 1,
  }) {
    return SaavnSearchProvider(
      query,
      page: page,
    );
  }

  @override
  SaavnSearchProvider getProviderOverride(
    covariant SaavnSearchProvider provider,
  ) {
    return call(
      provider.query,
      page: provider.page,
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
    String query, {
    int page = 1,
  }) : this._internal(
          (ref) => saavnSearch(
            ref as SaavnSearchRef,
            query,
            page: page,
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
          page: page,
        );

  SaavnSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.page,
  }) : super.internal();

  final String query;
  final int page;

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
        page: page,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SongModel>> createElement() {
    return _SaavnSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaavnSearchProvider &&
        other.query == query &&
        other.page == page;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SaavnSearchRef on AutoDisposeFutureProviderRef<List<SongModel>> {
  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `page` of this provider.
  int get page;
}

class _SaavnSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<SongModel>>
    with SaavnSearchRef {
  _SaavnSearchProviderElement(super.provider);

  @override
  String get query => (origin as SaavnSearchProvider).query;
  @override
  int get page => (origin as SaavnSearchProvider).page;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
