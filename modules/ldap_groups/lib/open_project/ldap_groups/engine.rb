module OpenProject::LdapGroups
  class Engine < ::Rails::Engine
    engine_name :openproject_ldap_groups

    include OpenProject::Plugins::ActsAsOpEngine

    register "openproject-ldap_groups",
             author_url: "https://github.com/opf/openproject-ldap_groups",
             bundled: true,
             settings: {
               default: {}
             } do
      menu :admin_menu,
           :plugin_ldap_groups,
           { controller: "/ldap_groups/synchronized_groups", action: :index },
           parent: :authentication,
           last: true,
           caption: ->(*) { I18n.t("ldap_groups.label_menu_item") },
           # enterprise_feature: "ldap_groups"
    end

    add_cron_jobs do
      {
        "LdapGroups::SynchronizationJob": {
          cron: "*/30 * * * *", # Run every 30 minutes
          class: LdapGroups::SynchronizationJob.name
        }
      }
    end

    patches %i[LdapAuthSource Group User]
  end
end
