cask 'adobe-cs6-master-collection' do
    version 'CS6'
    sha256 'cf98947c2f6bad65ec863f76e77de70cc241328dd55efd08115f97e3027c48ec'
  
    # This Cask only works for Adobe dmgs containing the deploy folder,
    # i.e. the Adobe Collections, not the single Product Installers!
  
    # For correct download URL see links provided at
    # https://helpx.adobe.com/x-productkb/policy-pricing/cs6-product-downloads.html
    url "http://trials.adobe.com/AdobeProducts/legacy/99CABBAC-C975-4A06-8D99-064C6871EE80/STAM/CS6/osx10/MasterCollection_#{version}_LS16.dmg",
        user_agent: :fake,
        cookies:    { 'MM_TRIALS' => '1234' }
    name 'Adobe CS6 Master Collection' # name must exactly match directory in dmg!
    homepage 'https://www.adobe.com/mena_en/products/creativesuite.html'
  
    # staged_path not available in Installer/Uninstall Stanza, workaround by nesting with preflight/postflight
    # see https://github.com/caskroom/homebrew-cask/pull/8887
    # and https://github.com/caskroom/homebrew-versions/pull/296
  
    preflight do
      processes = system_command '/bin/launchctl', args: ['list']
  
      if processes.stdout.lines.any? { |line| line =~ %r{^\d+\t\d\tcom.apple.SafariNotificationAgent$} }
        system_command '/usr/bin/killall', args: ['-kill', 'SafariNotificationAgent']
      end
  
      language = case MacOS.language
                 when %r{^de} then 'de_DE'
                 when 'en-GB' then 'en_GB'
                 when %r{^es} then 'es_ES'
                 when %r{^fr} then 'fr_FR'
                 when %r{^it} then 'it_IT'
                 when %r{^ja} then 'ja_JP'
                 when %r{^nl} then 'nl_NL'
                 else
                   'en_US'
                 end
  
      system_command "#{staged_path}/Adobe CS6 Master Collection/Install.app/Contents/MacOS/Install",
                     args: [
                             '--mode=silent', "--deploymentFile=#{staged_path}/Adobe CS6 Master Collection/deploy/install-#{language}.xml"
                           ],
                     sudo: true
  
      FileUtils.cp "#{staged_path}/Adobe CS6 Master Collection/deploy/uninstall-en_US.xml", "#{staged_path}/uninstall.xml"
    end
  
    uninstall_preflight do
      processes = system_command '/bin/launchctl', args: ['list']
  
      if processes.stdout.lines.any? { |line| line =~ %r{^\d+\t\d\tcom.apple.SafariNotificationAgent$} }
        system_command '/usr/bin/killall', args: ['-kill', 'SafariNotificationAgent']
      end
  
      system_command "#{staged_path}/Adobe CS6 Master Collection/Install.app/Contents/MacOS/Install",
                     args: [
                             '--mode=silent', "--deploymentFile=#{staged_path}/Adobe CS6 Master Collection/deploy/uninstall-en_US.xml"
                           ],
                     sudo: true
    end
  
    caveats <<~EOS
      Installation or Uninstallation may fail with Exit Code 19 (Conflicting Processes running) if Browsers, Safari Notification Service or SIMBL Services (e.g. Flashlight) are running or Adobe Creative Cloud or any other Adobe Products are already installed. See Logs in /Library/Logs/Adobe/Installers if Installation or Uninstallation fails, to identifify the conflicting processes.
    EOS
  end
