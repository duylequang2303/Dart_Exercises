// lib/models/notification_model.dart

enum LoaiThongBao { luanTap, anUong, lichTrinh, nuocUong }

class ThongBaoModel {
  final String id;
  final LoaiThongBao loai;
  final String tieuDe;
  final String noiDung;
  final String thoiGian;
  bool daDoc;

  ThongBaoModel({
    required this.id,
    required this.loai,
    required this.tieuDe,
    required this.noiDung,
    required this.thoiGian,
    this.daDoc = false,
  });
}

// Dữ liệu mẫu — sau này thay bằng data thật từ Provider/Hive
class ThongBaoData {
  static List<ThongBaoModel> layDanhSach() {
    return [
      ThongBaoModel(
        id: 'n1',
        loai: LoaiThongBao.luanTap,
        tieuDe: 'Chưa tập hôm nay!',
        noiDung: 'Bạn chưa mở app từ sáng sớm. Chỉ 20 phút cardio là đủ để đạt mục tiêu hôm nay.',
        thoiGian: 'Vừa xong',
        daDoc: false,
      ),
      ThongBaoModel(
        id: 'n2',
        loai: LoaiThongBao.anUong,
        tieuDe: 'Đến giờ ăn trưa rồi!',
        noiDung: 'Bạn còn 650 kcal trong mục tiêu hôm nay. Đừng quên ghi lại bữa trưa nhé.',
        thoiGian: '12:00',
        daDoc: false,
      ),
      ThongBaoModel(
        id: 'n3',
        loai: LoaiThongBao.lichTrinh,
        tieuDe: 'Lịch tập lúc 17:00 hôm nay',
        noiDung: 'Bạn có buổi tập Yoga đã lên lịch lúc 17:00. Hãy chuẩn bị trước 15 phút!',
        thoiGian: '10:30',
        daDoc: false,
      ),
      ThongBaoModel(
        id: 'n4',
        loai: LoaiThongBao.nuocUong,
        tieuDe: 'Uống nước đi bạn ơi!',
        noiDung: 'Bạn mới uống 1.2L, còn thiếu 1.3L nữa mới đạt mục tiêu ngày hôm nay.',
        thoiGian: '09:00',
        daDoc: false,
      ),
      ThongBaoModel(
        id: 'n5',
        loai: LoaiThongBao.luanTap,
        tieuDe: 'Bạn đã bỏ lỡ buổi tập',
        noiDung: 'Buổi tập Strength hôm qua chưa hoàn thành. Hãy bù lại hôm nay để không phá chuỗi streak.',
        thoiGian: 'Hôm qua 08:00',
        daDoc: true,
      ),
      ThongBaoModel(
        id: 'n6',
        loai: LoaiThongBao.anUong,
        tieuDe: 'Nhắc nhở bữa tối',
        noiDung: 'Hôm qua bạn bỏ qua bữa tối. Ăn đủ bữa giúp duy trì năng lượng và tránh thèm ăn đêm.',
        thoiGian: 'Hôm qua 19:30',
        daDoc: true,
      ),
      ThongBaoModel(
        id: 'n7',
        loai: LoaiThongBao.lichTrinh,
        tieuDe: 'Nhắc lịch tuần này',
        noiDung: 'Tuần này bạn có 3 buổi tập đã lên lịch. Còn 2 buổi chưa hoàn thành.',
        thoiGian: 'Hôm qua 07:00',
        daDoc: true,
      ),
    ];
  }
}