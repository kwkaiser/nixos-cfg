{pkgs, ...}: {
  home.packages = with pkgs; [
    gh
    gh-dash
    diffnav
  ];

  # gh-dash config with diffnav as diff pager
  xdg.configFile."gh-dash/config.yml".text = ''
    prSections:
      - title: My Pull Requests
        filters: is:open author:@me
      - title: Needs My Review
        filters: is:open review-requested:@me
      - title: Involved
        filters: is:open involves:@me -author:@me

    issuesSections:
      - title: My Issues
        filters: is:open author:@me
      - title: Assigned
        filters: is:open assignee:@me

    defaults:
      prsLimit: 20
      issuesLimit: 20
      preview:
        open: true
        width: 60

    pager:
      diff: diffnav
  '';
}
