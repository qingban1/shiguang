# 《拾岸微光 (Glimmer Coast)》工程开发交付说明书 (README.md)

---

## 一、 产品定位与核心价值

* **产品名称**：拾岸微光 (Glimmer Coast)
* **核心定位**：无社交压力、无私信搭讪、专注生活碎片记录与情绪共鸣的晨曦轻社区。
* **主要痛点解决**：
  1. 现代社交平台的“被审视羞耻”与点赞/粉丝量焦虑。
  2. 开放式评论区与私信带来的低俗骚扰、恶意杠精与人际消耗。
  3. 日常随手拍缺乏排版导致的视觉分享门槛。
* **独特操作路径**：
  * **单向情绪回响**：彻底阻断开放式键盘文字输入，仅保留 4 种预设正向回响（治愈/加油/好运/抱抱）。
  * **双面相纸 3D 翻转**：正面看真实环境印记切片，点击原地翻转查看背面随笔。
  * **同频雷达**：单选微状态标签，顶栏实时呼吸感知同频共振人数。

---

## 二、 视觉色彩与硬件规范对照

### 2.1 硬件物理规范 (iPhone 16 Pro)
* **逻辑分辨率**：`402 pt × 874 pt`
* **屏幕曲率 (Corner Radius)**：`55 pt`
* **硬件特性**：顶部搭载可交互展开的灵动岛 (Dynamic Island)，底部带有 Home Indicator。

### 2.2 色彩体系标准 (Hex & RGBA)
| 角色分类 | 命名与色值 | 说明与应用场景 |
| :--- | :--- | :--- |
| **主色 (Twilight)** | `#6C5CE7` / `#4A3B69` | 暮光紫。主标题、主要标签背景、重要视觉强调。 |
| **辅色 (Dawn)** | `#FF8FA3` / `#FFF0F5` | 晨霞粉。卡片外发光、弥散过渡层、抱抱回响。 |
| **点缀色 (Amber)** | `#FF9F43` / `#FF7800` | 暖阳金橘。同频雷达高亮胶囊、中心发布按键 (+)、加油回响。 |
| **透亮非白背景** | `#FAF7FD` → `#FFF0F5` → `#FFFBF4` | 晨曦三色网格微光渐变，彻底废除生硬刺眼的纯白底板。 |

---

## 三、 原型文件与交互状态完整对照表

| 界面/模态编号 | 对应代码元素 ID | 核心交互与触发事件 | 数据与状态闭环 |
| :--- | :--- | :--- | :--- |
| **登录与认证** | `#screen-auth` | 1. Sign in with Apple 一键登录<br>2. 手机验证码 60s 倒计时与自动回填<br>3. EULA 用户协议勾选拦截与抖动提醒<br>4. “先逛逛海岸”访客通道 | 登录成功后全屏平滑向外滑出；在个人中心点击注销后平滑回退复原。 |
| **灵动岛** | `#dynamic-island` | 单击胶囊展开 `#island-expanded`，展示“同频电台与海潮音浪波形”；再次点击收起。 | 顶部常驻，支持动态呼吸跳动。 |
| **微光广场** | `#tab-feed` | 1. 顶部同频雷达 `#radar-label` 点击筛选<br>2. 右上角按钮触发旋转刷新<br>3. 单列流图文展示与 3D 翻转卡片 (`flipCard`)<br>4. 4 款回响按钮触发真实彩色粒子喷射 (`sendReaction`) | 真实的 DOM 操作与粒子爆破动效，支持本地数字递增与撤回。 |
| **生活微习惯** | `#tab-collage` | 1. 7 格连载生活习惯进度条<br>2. 社区微光画卷四宫格展示<br>3. 点击“存为壁纸”呼出 `#modal-wallpaper` | 弹出 1080×1920 竖版壁纸弹窗并提供保存相册成功反馈。 |
| **投递模态框** | `#modal-post` | 1. 点击底栏高亮 `+` 号呼出全屏模态 Sheet<br>2. “更换相纸”切换预设高清摄影<br>3. 宋体/手写体即时切换<br>4. 绑定单选微状态 Tag<br>5. 点击“放飞”执行发布 | 客户端实时组装数据并在 `#feed-container` 顶端动态追加全新卡片。 |
| **足迹中心** | `#tab-profile` | 1. 情绪温度琉璃瓶内置浮动粒子<br>2. 月份相纸抽屉缩略图平铺<br>3. 账号退出登录入口 (`handleLogout`) | 琉璃瓶根据历史累积回响展示总温度；退出按钮重置认证浮层。 |
| **安全合规抽屉**| `#sheet-safety` | 针对任意卡片点击“`···`”弹出：<br>1. 拉黑创作者 (`blockCurrentAuthor`)<br>2. 举报违规动态 (`reportCurrentPost`) | 符合苹果 Guideline 1.2 审查标准，拉黑后即刻在本地移除该内容。 |

---

## 四、 苹果审核 (App Store Review Guidelines) 落地指引

1. **Guideline 1.2 (UGC 安全要求)**：
   * 必须在登录首屏前置强调《最终用户许可协议 (EULA)》，明确声明零容忍策略。
   * 每张卡片均具备一键拉黑并隐藏创作者动态的逻辑，并提供 24 小时举报通道。
2. **Guideline 4.0 (设计与认证要求)**：
   * 采用第三方社交账号登录时，必须将 **Sign in with Apple** 置于最高优先级。
   * 控件深度集成 iOS 原生触感反馈 (`UIImpactFeedbackGenerator`)。
3. **Guideline 5.1.1 (数据隐私最小化)**：
   * 环境微印记只调用模糊城市级天气与时段，不索取与存储用户的精细 GPS 经纬度。

---

## 五、 原生 SwiftUI 核心架构参考代码

### 5.1 拍立得 3D 翻转卡片组件 (SwiftUI)
```swift
import SwiftUI

struct PolaroidCardView: View {
    let post: PostModel
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            // 正面：实景照片与环境微印记
            PolaroidFrontView(post: post)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            
            // 反面：手写随感
            PolaroidBackView(post: post)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}# shiguang
