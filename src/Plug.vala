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
            var hardware_view = new HardwareView() { valign = Gtk.Align.CENTER };
            var firmware_view = new FirmwareView();

            // The rest of the code remains unchanged.
