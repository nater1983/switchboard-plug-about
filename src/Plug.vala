/*
* Copyright 2020 elementary, Inc. (https://elementary.io)
*           2015 Ivo Nunes, Akshay Shekher
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

using System.IO;
using System.Collections.Generic;

public class About.Plug : Switchboard.Plug
{
    // ... (Rest of the original code)

    private Dictionary<string, string> ReadOsRelease()
    {
        var osReleasePath = "/etc/os-release";
        var osInfo = new Dictionary<string, string>();

        if (File.Exists(osReleasePath))
        {
            var lines = File.ReadAllLines(osReleasePath);
            foreach (var line in lines)
            {
                var parts = line.Split('=');
                if (parts.Length == 2)
                {
                    osInfo[parts[0].Trim()] = parts[1].Trim().Trim('\"');
                }
            }
        }

        return osInfo;
    }

    public override Gtk.Widget get_widget()
    {
        if (main_grid == null)
        {
            var operating_system_view = new OperatingSystemView();

            // Read /etc/os-release file
            var osInfo = ReadOsRelease();

            // Display operating system information
            var osNameLabel = new Gtk.Label(osInfo.ContainsKey("PRETTY_NAME") ? osInfo["PRETTY_NAME"] : "Operating System Information Not Available");
            var osVersionLabel = new Gtk.Label(osInfo.ContainsKey("VERSION_ID") ? "Version: " + osInfo["VERSION_ID"] : "Version Information Not Available");
            var osInfoBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
            osInfoBox.PackStart(osNameLabel, false, false, 0);
            osInfoBox.PackStart(osVersionLabel, false, false, 0);
            operating_system_view.add(osInfoBox);

            // Other views remain unchanged
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

    // 'search' returns results like ("Keyboard → Behavior → Duration", "keyboard<sep>behavior")
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
