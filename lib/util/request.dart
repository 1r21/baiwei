class Api<T> {
  final int code;
  final T data;
  final String message;

  Api({required this.code, required this.data, required this.message});

  Api.fromJson(Map<String, dynamic> json)
      : this(code: json['code'], data: json['data'], message: json['message']);
}
