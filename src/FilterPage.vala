/*  This file is part of corebird, a Gtk+ linux Twitter client.
 *  Copyright (C) 2013 Timm Bäder
 *
 *  corebird is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  corebird is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with corebird.  If not, see <http://www.gnu.org/licenses/>.
 */
[GtkTemplate (ui = "/org/baedert/corebird/ui/filter-page.ui")]
class FilterPage : Gtk.ScrolledWindow, IPage {
  public int id { get; set; }
  public unowned MainWindow main_window {get; set;}
  public unowned Account account        {get; set;}
  private Gtk.RadioToolButton tool_button;
  [GtkChild]
  private Gtk.ListBox filter_list;
  private bool inited = false;

  public FilterPage (int id) {
    this.id = id;
    filter_list.set_header_func (header_func);
    filter_list.add (new AddFilterEntry ());
    filter_list.row_activated.connect ((row) => {
      if (row is AddFilterEntry) {
        var dialog = new ModifyFilterDialog (main_window, account);
        dialog.filter_added.connect (filter_added_cb);
        dialog.show_all ();
      } else if (row is FilterListEntry) {
        var filter_row = (FilterListEntry) row;
        var dialog = new ModifyFilterDialog (main_window, account, filter_row.filter);
        dialog.filter_added.connect (filter_added_cb);
        dialog.show_all ();
      }
    });
  }

  public void on_join (int page_id, va_list arg_list) {
    if (inited)
      return;

    foreach (Filter f in account.filters) {
      var entry = new FilterListEntry (f);
      filter_list.add (entry);
    }

    inited = true;
  }

  /**
   * Called when the user adds a new Filter via the AddFilterDialog
   *
   **/
  private void filter_added_cb (Filter f, bool created) {
    if (created) {
      var entry = new FilterListEntry (f);
      filter_list.add (entry);
    } else {
      var children = filter_list.get_children ();
      foreach (Gtk.Widget w in children) {
        if (!(w is FilterListEntry))
          continue;

        var le = (FilterListEntry) w;
        if (le.filter.id == f.id) {
          le.content = f.content;
          break;
        }
      }
    }
  }

  private void header_func (Gtk.ListBoxRow row, Gtk.ListBoxRow? row_before) { //{{{
    if (row_before == null)
      return;

    Gtk.Widget header = row.get_header ();
    if (header == null) {
      header = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
      header.show ();
      row.set_header (header);
    }
  } //}}}



  public void on_leave () {}
  public void create_tool_button(Gtk.RadioToolButton? group) {
    tool_button = new BadgeRadioToolButton(group, "corebird-filter-symbolic");
    tool_button.tooltip_text = _("Filters");
    tool_button.label = _("Filters");
  }
  public Gtk.RadioToolButton? get_tool_button() { return tool_button; }
}




class AddFilterEntry : Gtk.ListBoxRow {
  public AddFilterEntry () {
    var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
    var img = new Gtk.Image.from_icon_name ("list-add-symbolic", Gtk.IconSize.DIALOG);
    img.pixel_size = 32;
    img.margin_left = 10;
    img.hexpand = true;
    img.halign = Gtk.Align.END;
    box.pack_start (img);
    var l = new Gtk.Label (_("Add new Filter"));
    l.hexpand = true;
    l.halign = Gtk.Align.START;
    box.pack_start (l);
    add (box);
  }
}
