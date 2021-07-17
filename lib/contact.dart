class Contact {
  static const tblContact = 'contacts';
  static const colId = 'id';
  static const colName = 'name';
  static const colMobile = 'mobile';
  static const colAddress = 'address';
  static const colBirthday = 'birthday';
  static const colSearch = 'search';
  static const colGender = 'gender';
  static const colImg = 'img';

  int id;
  String name;
  String mobile;
  String address;
  String birthday;
  String search;
  String gender;
  String img;

  Contact({
    this.id,
    this.name,
    this.mobile,
    this.address,
    this.birthday,
    this.search,
    this.gender,
    this.img,
  });

  Contact.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    name = map[colName];
    mobile = map[colMobile];
    address = map[colAddress];
    birthday = map[colBirthday];
    gender = map[colGender];
    img = map[colImg];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colName: name,
      colMobile: mobile,
      colAddress: address,
      colBirthday: birthday,
      colGender: gender,
      colImg: img,
    };
    if (id != null) map[colId] = id;
    return map;
  }
}
