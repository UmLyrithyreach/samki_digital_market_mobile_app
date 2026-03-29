class AppEnv {
  // Loaded from --dart-define or --dart-define-from-file
  static const String sanityProjectId =
      String.fromEnvironment('NEXT_PUBLIC_SANITY_PROJECT_ID', defaultValue: '');
  static const String sanityDataset =
      String.fromEnvironment('NEXT_PUBLIC_SANITY_DATASET', defaultValue: '');
  static const String sanityOrgId =
      String.fromEnvironment('NEXT_PUBLIC_SANITY_ORG_ID', defaultValue: '');
  static const String sanityApiWriteToken = String.fromEnvironment(
    'NEXT_PUBLIC_SANITY_API_WRITE_TOKEN',
    defaultValue: '',
  );
  static const String clerkPublishableKey = String.fromEnvironment(
    'NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static bool get hasSanityConfig =>
      sanityProjectId.trim().isNotEmpty && sanityDataset.trim().isNotEmpty;
}
