default_platform(:ios)

platform :ios do
  desc "Build the app and send it to App Store Connect"
  lane :release do
    api_key = app_store_connect_api_key(
      key_id: ENV["APP_STORE_CONNECT_KEY_ID"],
      issuer_id: ENV["APP_STORE_CONNECT_ISSUER_ID"],
      key_filepath: ENV["APP_STORE_CONNECT_KEY_PATH"],
      duration: 1200,
      in_house: false
    )

    build_app(
      project: "SwimAI.xcodeproj",
      scheme: "SwimAI",
      export_method: "app-store",
      export_options: {
        provisioningProfiles: {
          ENV["BUNDLE_ID"] => ENV["PROVISIONING_PROFILE_SPECIFIER"]
        }
      }
    )

    upload_to_testflight(
      api_key: api_key,
      skip_waiting_for_build_processing: true,
      skip_submission: true
    )
  end
end
