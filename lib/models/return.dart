class Return<T> {
  bool status;
  T? data;
  bool error;

  Return({required this.status, this.data, this.error = false});
}
