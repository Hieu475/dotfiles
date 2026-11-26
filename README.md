# dotfiles: i3 trên Ubuntu 24.04

Cấu hình i3 tối giản: tự chia ô (autotiling), gom tab, thanh bar i3blocks bấm được, hai màn hình, gõ tiếng Việt (ibus Bamboo).

## Thành phần

| Thư mục | Nội dung |
|---|---|
| `.config/i3/` | Config i3 tách file (`workspaces`, `appearance`, `rules`, `keybindings`, `autostart`) và các script |
| `.config/i3blocks/` | Thanh bar: mỗi mục là một script, bấm / bấm phải / lăn chuột |
| `.config/rofi`, `picom`, `qt5ct`, `gtk-3.0`, `gtk-4.0` | Launcher, compositor, giao diện tối |
| `.config/xfce4/.../xfce4-power-manager.xml` | Quản lý pin và nguồn (không hiện icon khay, bar đã có mục pin) |
| `.config/autostart/` | Ẩn một số ứng dụng chạy nền (Evolution, update-notifier...) |
| `.xsessionrc` | `QT_QPA_PLATFORMTHEME=qt5ct` |

## Gói cần cài

```sh
sudo apt install i3 i3lock i3blocks xss-lock dex rofi picom autorandr python3-i3ipc \
  policykit-1-gnome pavucontrol network-manager network-manager-gnome xfce4-power-manager \
  xfce4-notifyd xfconf qt5ct flameshot copyq thunar ibus-bamboo btop \
  brightnessctl xinput zenity libnotify-bin x11-utils x11-xserver-utils pulseaudio-utils libglib2.0-bin
```

| Gói | Script dùng để làm gì |
|---|---|
| `x11-xserver-utils` | `xrandr`, `xset`, `xsetroot` (màn hình, hẹn giờ khóa, nền) |
| `x11-utils` | `xkill` (đóng cưỡng bức) |
| `xinput` | cấu hình touchpad |
| `pulseaudio-utils` | `pactl` (âm lượng) |
| `libnotify-bin` | `notify-send` |
| `zenity` | lịch khi bấm đồng hồ trên bar |

Ngoài ra cần: Ghostty, Brave, font **JetBrainsMono Nerd Font**.

## Kiểm tra trước khi dùng

```sh
./check.sh
```

Kiểm tra cú pháp i3, shell, Python; mọi script được config gọi tới phải tồn tại và chạy được;
cảnh báo nếu thiếu chương trình. Không kiểm tra được: lệnh viết sau `bindsym` và hành vi khi i3 đang chạy.

## Đo hiệu năng

Chạy trong phiên i3, mở cùng một bộ ứng dụng mỗi lần so sánh:

```sh
./bench.py 60 > truoc.txt   # đổi config, đăng nhập lại
./bench.py 60 > sau.txt
```

## Chương trình tự chạy

`dex` đọc `/etc/xdg/autostart` và tự khởi động `nm-applet`, `picom`, `xfce4-power-manager`,
nên `autostart` của i3 không gọi lại chúng. `pasystray` (nếu đã cài) bị ẩn bằng
`.config/autostart/pasystray.desktop` vì bar đã có mục âm lượng. Xem danh sách:

```sh
dex --autostart --environment i3 --dry-run
```

`exec_always` chạy khi khởi động và khi *restart* i3 (`Super + Shift + r`), không chạy khi *reload*.

## Autotiling và chia thủ công

`Super + v` (chia dọc) và `Super + Ctrl + h` (chia ngang) được giữ cho cửa sổ đó tới khi cửa sổ
tiếp theo mở ra cạnh nó. Lựa chọn bị hủy nếu cửa sổ đó được chuyển sang khung hoặc workspace khác,
vào scratchpad, chuyển thành nổi hoặc nằm trong khung tab.

## CopyQ

Giới hạn lịch sử clipboard (chạy khi CopyQ đang mở; các mục vượt quá giới hạn sẽ bị xóa):

```sh
copyq config maxitems 100
```

## Cài đặt

Sao lưu config cũ trước, rồi chép vào thư mục home:

```sh
cp -a --backup=numbered .config .xsessionrc ~/
```

Thông báo tự đóng sau 10 giây, kể cả thông báo "không bao giờ hết hạn":

```sh
xfconf-query -c xfce4-notifyd -p /expire-timeout-enabled -n -t bool -s true
xfconf-query -c xfce4-notifyd -p /expire-timeout -n -t int -s 10
xfconf-query -c xfce4-notifyd -p /expire-timeout-allow-override -n -t bool -s false
```

Phím độ sáng cần quyền nhóm `video` (đăng nhập lại sau khi chạy):

```sh
sudo usermod -aG video "$USER"
```

## Cần chỉnh theo máy

- Tên màn hình laptop được nhận theo mẫu `eDP*`; màn hình ngoài tự nhận.
- Font, tên card mạng, pin (`BAT*`) được script tự tìm.
- Phím `Super + /` mở bảng phím tắt (`.config/i3/cheatsheet.txt`).
