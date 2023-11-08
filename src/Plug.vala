using System.IO;
using System.Collections.Generic;

public class About.Plug : Switchboard.Plug {
    private const string OPERATING_SYSTEM = "operating-system";
    private const string HARDWARE = "hardware";
    private const string FIRMWARE = "firmware";

    private Gtk.Grid main_grid;
    private Gtk.Stack stack;

    private Dictionary<string, string> ReadOsRelease() {
        var osReleasePath = "/etc/os-release";
        var osReleaseInfo = new Dictionary<string, string>();

        if (File.Exists(osReleasePath)) {
            var lines = File.ReadAllLines(osReleasePath);
            foreach (var line in lines) {
                var parts = line.Split(new char[] { '=' }, 2);
                if (parts.Length == 2) {
                    osReleaseInfo[parts[0]] = parts[1].Trim(new char[] { '"', ' ' });
                }
            }
        }

        return osReleaseInfo;
    }

    public Plug () {
        GLib.Intl.bindtextdomain (About.GETTEXT_PACKAGE, About.LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (About.GETTEXT_PACKAGE, "UTF-8");

        var osReleaseInfo = ReadOsRelease();
        var osName = osReleaseInfo.ContainsKey("NAME") ? osReleaseInfo["NAME"] : "Unknown OS";

        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("about", null);
        settings.set ("about/os", osName);

        Object (
            category: Category.SYSTEM,
            code_name: "io.elementary.switchboard.about",
            display_name: _("System"),
            description: _("View operating system and hardware information"),
            icon: "application-x-firmware",
            supported_settings: settings
        );
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            var operating_system_view = new OperatingSystemView ();

            var hardware_view = new HardwareView () {
                valign = Gtk.Align.CENTER
            };

            var firmware_view = new FirmwareView ();

            stack = new Gtk.Stack () {
                vexpand = true
            };
            stack.add_titled (operating_system_view, OPERATING_SYSTEM, _("Operating System"));
            stack.add_titled (hardware_view, HARDWARE, _("Hardware"));
            stack.add_titled (firmware_view, FIRMWARE, _("Firmware"));

            var stack_switcher = new Gtk.StackSwitcher () {
                halign = Gtk.Align.CENTER,
                homogeneous = true,
                margin_top = 24,
                stack = stack
            };

            main_grid = new Gtk.Grid () {
                row_spacing = 12
            };
            main_grid.attach (stack_switcher, 0, 0);
            main_grid.attach (stack, 0, 1);
            main_grid.show_all ();
        }

        return main_grid;
    }

    public override void shown () {
    }

    public override void hidden () {
    }

    public override void search_callback (string location) {
        switch (location) {
            case OPERATING_SYSTEM:
            case HARDWARE:
            case FIRMWARE:
                stack.set_visible_child_name (location);
                break;
            default:
                stack.set_visible_child_name (OPERATING_SYSTEM);
                break;
        }
    }

    public override async Gee.TreeMap<string, string> search (string search) {
        var search_results = new Gee.TreeMap<string, string> (
            (GLib.CompareDataFunc<string>)strcmp,
            (Gee.EqualDataFunc<string>)str_equal
        );

        search_results.set ("%s → %s".printf (display_name, _("Operating System Information")), OPERATING_SYSTEM);
        search_results.set ("%s → %s".printf (display_name, _("Hardware Information")), HARDWARE);
        search_results.set ("%s → %s".printf (display_name, _("Firmware")), FIRMWARE);
        search_results.set ("%s → %s".printf (display_name, _("Restore Default Settings")), OPERATING_SYSTEM);
        search_results.set ("%s → %s".printf (display_name, _("Suggest Translations")), OPERATING_SYSTEM);
        search_results.set ("%s → %s".printf (display_name, _("Send Feedback")), OPERATING_SYSTEM);
        search_results.set ("%s → %s".printf (display_name, _("Report a Problem")), OPERATING_SYSTEM);
        search_results.set ("%s → %s".printf (display_name, _("Get Support")), OPERATING_SYSTEM);
        search_results.set ("%s → %s".printf (display_name, _("Updates")), OPERATING_SYSTEM);

        return search_results;
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating System plug");
    var plug = new About.Plug ();
    return plug;
}
