class Bouncer {
    final String code;
    final String name;
    final String grade;

    Bouncer({
        required this.code,
        required this.name,
        required this.grade,
    });

    bool get isSuccess => code != null;
    
    factory Bouncer.fromJson(Map<String, dynamic> json) {
        return Bouncer(
            code: json['bouncer_code'],
            name: json['bouncer_name'],
            grade: json['grade'],
        );
    } 
}