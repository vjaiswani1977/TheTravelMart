import '../models/contractor.dart';

// DUMMY DATA — swap with OdooService.fetchContractors() when ready
class ContractorDataSource {
  static final instance = ContractorDataSource._();
  ContractorDataSource._();

  static const List<Contractor> _data = [
    Contractor(id:1, name:'James Anderson',   serviceType:'Tour Guide', pricePerHour:35, rating:4.8, imageUrl:'https://randomuser.me/api/portraits/men/32.jpg',   description:'Expert aviation guide with 10+ years experience.'),
    Contractor(id:2, name:'Sarah Mitchell',   serviceType:'Tour Guide', pricePerHour:35, rating:4.9, imageUrl:'https://randomuser.me/api/portraits/women/44.jpg', description:'Certified aviation enthusiast and event guide.'),
    Contractor(id:3, name:'Robert Chen',      serviceType:'Tour Guide', pricePerHour:35, rating:4.7, imageUrl:'https://randomuser.me/api/portraits/men/55.jpg',   description:'Former air traffic controller turned guide.'),
    Contractor(id:4, name:'Emily Rodriguez',  serviceType:'Tour Guide', pricePerHour:35, rating:4.6, imageUrl:'https://randomuser.me/api/portraits/women/22.jpg', description:'Multilingual guide specializing in aircraft history.', isAvailable:false),
    Contractor(id:5, name:'Lisa Thompson',    serviceType:'Sitter',     pricePerHour:30, rating:4.9, imageUrl:'https://randomuser.me/api/portraits/women/65.jpg', description:'Certified childcare professional, 8 years experience.'),
    Contractor(id:6, name:'Michael Brown',    serviceType:'Sitter',     pricePerHour:30, rating:4.7, imageUrl:'https://randomuser.me/api/portraits/men/41.jpg',   description:'Event sitter specializing in family activities.'),
    Contractor(id:7, name:'Jessica Park',     serviceType:'Sitter',     pricePerHour:30, rating:4.8, imageUrl:'https://randomuser.me/api/portraits/women/33.jpg', description:'CPR-certified sitter with aviation event experience.'),
    Contractor(id:8, name:'David Wilson',     serviceType:'Sitter',     pricePerHour:30, rating:4.5, imageUrl:'https://randomuser.me/api/portraits/men/28.jpg',   description:'Professional event sitter, great with all ages.'),
  ];

  Future<List<Contractor>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _data;
  }

  Future<List<Contractor>> getByType(String type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _data.where((c) => c.serviceType == type).toList();
  }
}
