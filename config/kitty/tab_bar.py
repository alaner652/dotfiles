from kitty.fast_data_types import Screen, get_options
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb, draw_title
from kitty.utils import color_as_int

opts = get_options()

# --- 精緻符號配置 ---
LEFT_SEP = "" 
RIGHT_SEP = ""
ACTIVE_ICON = ""  # 實心圓，增加重量感
INACTIVE_ICON = "" # 空心圓，增加輕盈感
GAP_SIZE = " "

def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_title_length: int, index: int, is_last: bool,
    extra_data: ExtraData,
) -> int:
    # 1. 抓取顏色
    window_bg = as_rgb(color_as_int(opts.background))
    conf_white = as_rgb(color_as_int(opts.foreground))
    conf_color4 = as_rgb(color_as_int(opts.color4))
    conf_color0 = as_rgb(color_as_int(opts.color0))

    # 2. 判斷狀態與動態圖示
    if tab.is_active:
        bg, fg = conf_color4, conf_color0
        icon = ACTIVE_ICON
    else:
        # Inactive 使用白色底，但文字用深灰(0x444444)
        bg, fg = conf_white, as_rgb(0x444444)
        icon = INACTIVE_ICON

    screen.cursor.x = before

    # --- 繪製流程 ---
    # 左尖三角
    screen.cursor.bg, screen.cursor.fg = window_bg, bg
    screen.draw(LEFT_SEP)

    # 膠囊內容
    screen.cursor.bg, screen.cursor.fg = bg, fg
    
    # [圖示] [編號] [標題] -> 增加一點點間距感
    screen.draw(f" {icon} {index} ") 
    
    # 繪製標題 (這裡會自動繼承上面的 fg 顏色)
    draw_title(draw_data, screen, tab, index)
    screen.draw(" ")

    # 右尖三角
    screen.cursor.bg, screen.cursor.fg = window_bg, bg
    screen.draw(RIGHT_SEP)
    
    # 間距
    screen.cursor.bg = window_bg
    screen.draw(GAP_SIZE)

    return screen.cursor.x
