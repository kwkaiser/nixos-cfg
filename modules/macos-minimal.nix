{ mkModuleOption, ... }:
{
  options.darwin.modules.macos-minimal = mkModuleOption { };

  config.darwin.modules.macos-minimal = { ... }: {
    system.defaults.CustomUserPreferences = {
      "com.apple.CloudSubscriptionFeatures.optIn"."545129924" = false;
      "com.apple.assistant.support"."Assistant Enabled" = false;
      "com.apple.sharingd".DiscoverableMode = "Off";
      "com.apple.SubmitDiagInfo".AutoSubmit = false;
      "com.apple.Safari" = {
        UniversalSearchEnabled = false;
        SuppressSearchSuggestions = true;
      };
      "com.apple.lookup.shared".LookupSuggestionsDisabled = true;
    };

    system.defaults.CustomSystemPreferences = {
      "/Library/Preferences/com.apple.applicationaccess" = {
        allowGenmoji = false;
        allowImagePlayground = false;
        allowImageWand = false;
        allowWritingTools = false;
        allowExternalIntelligenceIntegrations = false;
        allowExternalIntelligenceIntegrationsSignIn = false;
        allowAssistant = false;
        allowMailSummary = false;
        allowMailSmartReplies = false;
        allowSafariSummary = false;
        allowNotesTranscription = false;
        allowNotesTranscriptionSummary = false;
        allowVisualIntelligenceSummary = false;
        allowDiagnosticSubmission = false;
        allowCloudBackup = false;
        allowCloudDocumentSync = false;
        allowCloudDesktopAndDocuments = false;
        allowCloudPhotoLibrary = false;
        allowCloudAddressBook = false;
        allowCloudBookmarks = false;
        allowCloudCalendar = false;
        allowCloudFreeform = false;
        allowCloudKeychainSync = false;
        allowCloudMail = false;
        allowCloudNotes = false;
        allowCloudReminders = false;
        allowManagedAppsCloudSync = false;
      };
    };

    system.activationScripts.disableSharingServices.text = ''
      /usr/sbin/systemsetup -setremoteappleevents off >/dev/null 2>&1 || true
      /bin/launchctl disable system/com.apple.AEServer >/dev/null 2>&1 || true
      /bin/launchctl disable system/com.apple.smbd >/dev/null 2>&1 || true
      /bin/launchctl bootout system/com.apple.smbd >/dev/null 2>&1 || true
      /usr/sbin/cupsctl --no-share-printers >/dev/null 2>&1 || true
      /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop >/dev/null 2>&1 || true
    '';
  };
}
