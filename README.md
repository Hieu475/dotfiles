# dotfiles: i3 trên Ubuntu 24.04

Cấu hình i3 tối giản: tự chia ô (autotiling), gom tab, thanh bar i3blocks bấm được, hai màn hình, gõ tiếng Việt (ibus Bamboo).

## Thành phần

| Thư mục | Nội dung |
|---|---|
| `.config/i3/` | Config i3 tách file (`workspaces`, `appearance`, `rules`, `keybindings`, `autostart`) và các script |
| `.config/i3blocks/` | Thanh bar: mỗi mục là một script, bấm / bấm phải / lăn chuột |
| `.config/rofi`, `picom`, `qt5ct`, `gtk-3.0`, `gtk-4.0` | Launcher, compositor, giao diện tối |
| `.config/xfce4/.../xfce4-power-manager.xml` | Icon pin/nguồn trên khay |
| `.config/autostart/` | Ẩn một số ứng dụng chạy nền (Evolution, update-notifier...) |
| `.xsessionrc` | `QT_QPA_PLATFORMTHEME=qt5ct` |

## Gói cần cài

```sh
sudo apt install i3 i3status i3lock i3blocks xss-lock dex rofi picom feh arandr autorandr \
  brightnessctl python3-i3ipc policykit-1-gnome pasystray pavucontrol network-manager-gnome \
  xfce4-power-manager xfce4-notifyd qt5ct flameshot copyq thunar ibus-bamboo
```

Ngoài ra cần: Ghostty, Brave, btop, font **JetBrainsMono Nerd Font**.

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
