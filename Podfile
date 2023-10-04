# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Aspire Budgeting' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Aspire Budgeting
  pod 'GoogleAPIClientForREST/Sheets'
  pod 'GoogleAPIClientForREST/Drive'
  pod 'GoogleAPIClientForREST/Script'
  pod 'GoogleSignIn'
  pod 'GoogleSignInSwiftSupport'
  target 'Aspire BudgetingTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
        target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
      end
    end
  end
end
