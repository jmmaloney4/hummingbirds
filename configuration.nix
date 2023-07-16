{pkgs, ...}: {
  system.stateVersion = 23.05;

  imports = [
    ./hardware-configuration.nix
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  networking.hostName = "hbot2";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDC/GWpEzz27GGo+bDiOV7Nw/TNXfreLTm50XxAiXRW610QwNzg/8O/rJ4Ybj20S7VUQluATICbA/R3W32qrhs7dW7LhIYA9krq8OVYqckE+II9qi9uNze8BZeris+RqhmBYhqxungRr3pMfKmZLsMyBHQPkIPceMGjrxENxJiwfcGnY1hh5d2DeyGcihpNGIdRZdDrxSvuDnuqATxatMeLnnvo03MrJjBNv1nowswBXyhpBsPuI/ZGv3ZWVcW/kmtO6r4YBkXYTVR6VufEjeCFwPV7/tguoFdXkhtC8l07iNUjxj1KX9wK9V9z2Bndf5UttOFYKs5hG1679EgSkij6FgFrmKII0SEHlbFBB41v9mbbeHrm+KjZfHjkLGWDHRJl1jRLfEx2oceZki62SRPPnmu3SySYTypippGKwx3TSegHtkIRfwjCV2Xqkd17VO2co/U/6JQ6ML68bZk1x2PLq+zP+uZ4Gxutj7TRJiGk7O8Vcu+ixYZ6hmm6r7TQOh3LWCIHll/EK/ymsHhq8UhXKN5X4BWSf2JxhvgoDbkbRKwexF0RMM17vqTdc22M1LOitR0dtHUsrPaEjnWlCKpeAtL3XYob2O1U96G2Xa7/eeVfEAgVV/iXsIfpRfSDPFQGPyBlYUxHKpaNC/QTBFfCzzpE12PAsl1rJpE83yKOLQ==''
  ];

  # users.users.hbot.openssh.authorizedKeys.keys = [
  #   ''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDC/GWpEzz27GGo+bDiOV7Nw/TNXfreLTm50XxAiXRW610QwNzg/8O/rJ4Ybj20S7VUQluATICbA/R3W32qrhs7dW7LhIYA9krq8OVYqckE+II9qi9uNze8BZeris+RqhmBYhqxungRr3pMfKmZLsMyBHQPkIPceMGjrxENxJiwfcGnY1hh5d2DeyGcihpNGIdRZdDrxSvuDnuqATxatMeLnnvo03MrJjBNv1nowswBXyhpBsPuI/ZGv3ZWVcW/kmtO6r4YBkXYTVR6VufEjeCFwPV7/tguoFdXkhtC8l07iNUjxj1KX9wK9V9z2Bndf5UttOFYKs5hG1679EgSkij6FgFrmKII0SEHlbFBB41v9mbbeHrm+KjZfHjkLGWDHRJl1jRLfEx2oceZki62SRPPnmu3SySYTypippGKwx3TSegHtkIRfwjCV2Xqkd17VO2co/U/6JQ6ML68bZk1x2PLq+zP+uZ4Gxutj7TRJiGk7O8Vcu+ixYZ6hmm6r7TQOh3LWCIHll/EK/ymsHhq8UhXKN5X4BWSf2JxhvgoDbkbRKwexF0RMM17vqTdc22M1LOitR0dtHUsrPaEjnWlCKpeAtL3XYob2O1U96G2Xa7/eeVfEAgVV/iXsIfpRfSDPFQGPyBlYUxHKpaNC/QTBFfCzzpE12PAsl1rJpE83yKOLQ==''
  # ];

  nix.package = pkgs.nix;
  nix.gc.automatic = true;
  nix.nrBuildUsers = 1;

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.max-jobs = "auto";
}
