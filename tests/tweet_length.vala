
// XXX Vala does not support all the g_assert macros, see https://bugzilla.gnome.org/show_bug.cgi?id=704072

void normal () {
  string t = "ABC";
  assert (TweetUtils.calc_tweet_length (t) == 3);
}

void empty () {
  int l = TweetUtils.calc_tweet_length ("");
  message ("empty length %d", l);
}

void http_link () {
  string text = "https://foobar.org";
  assert (TweetUtils.calc_tweet_length (text) == 22);
}

int main (string[] args) {
  GLib.Test.init (ref args);
  GLib.Test.add_func ("/tweet-length/normal", normal);
  GLib.Test.add_func ("/tweet-length/empty", empty);
  GLib.Test.add_func ("/tweet-length/http-link", http_link);


  return GLib.Test.run ();
}
