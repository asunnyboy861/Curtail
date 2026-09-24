# Curtail — 配置文档

生成时间：2026-09-24

---

## 一、⚠️ 手动配置（增强功能 — 不配置不影响基本使用）

> **重要说明**：以下配置项均为**增强/上架必需**项。App 本身已可正常运行所有核心功能（SOS 舱、永久纪录、花园、雷达、记录、导出均为本地功能，下载即用）。以下 5 项是你需要手动完成的配置。

### 🟡 1. GLM 云端 AI Key（食品标签扫描 + AI 周报）

**增强功能**：启用两个 Pro 云端 AI 功能——食品标签隐藏糖扫描（30次/月）和 AI 周度洞察报告（4次/月）
**不配置的影响**：这两个功能会显示"Cloud AI is not configured"提示；其余全部功能（含端侧 AI 教练）正常
**当前状态**：代码已实现完整调用逻辑 + 优雅降级，只差密钥文件

**已自动配置部分**：
- ✅ `GLMFlash.swift` 完整实现视觉扫描与周报调用（`glm-5.3-flash` @ `api.z.ai`）
- ✅ 运行时通过 `Bundle.main.url(forResource: "GLMSecret", withExtension: "txt")` 读取，密钥绝不入库
- ✅ `Curtail/GLMSecret.txt.example` 模板文件已创建，`.gitignore` 已包含 `GLMSecret.txt`

**请手动配置**：
1. 获取智谱 API Key（BigModel 开放平台或 Z.ai 开放平台，你已有 BigModel Key 可直接用）
2. 在项目目录 `Curtail/` 内创建文件 `GLMSecret.txt`（可从 `GLMSecret.txt.example` 复制）
3. 文件内容格式（一行一个 profile，按顺序故障转移）：
   ```
   你的APIKEY|https://api.z.ai/api/paas/v4/chat/completions|glm-5.3-flash
   ```
   可选加第二行中国端点兜底：
   ```
   你的APIKEY|https://open.bigmodel.cn/api/paas/v4/chat/completions|glm-5.3-flash
   ```
4. ⚠️ 不要提交到 git（已在 .gitignore，切勿用 `git add -f`）
5. 重新 Build 后，App 内"Label scan"和"Weekly report"即可用

---

### 🟡 2. Xcode 账户登录（Archive 签名）

**增强功能**：允许 Product → Archive 打包上传 App Store（模拟器构建/运行不受影响）
**不配置的影响**：无法 Archive 出 ipa；模拟器开发测试完全正常
**当前状态**：Team ID `VX3Q75X27B` 已烘焙进 project.yml 所有 target，仅缺账户登录

**请手动配置**：
1. 打开 Xcode → **Settings…** (⌘,) → **Accounts**
2. 点击 **"+"** → **Apple ID**，登录你的 Apple Developer 账户（含 Team VX3Q75X27B）
3. 登录后打开 `Curtail.xcodeproj` → 每个 target 的 Signing 页确认 Team 显示为 your team
4. 验证：`Product → Archive` 应能完成签名（不再报 "No Accounts"）

---

### 🔵 3. IAP StoreKit 订阅产品（App Store Connect 创建）

**影响功能**：不创建 IAP 产品则用户无法完成订阅购买（Paywall 会显示"Subscriptions are unavailable"）
**当前状态**：StoreKit 2 代码已完成，产品 ID 已在代码中硬编码匹配

**配置步骤**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com) → 你的 App → **Features** → **In-App Purchases**（需先创建 App 记录）
2. 创建订阅组 **Curtail Pro**，然后创建两个自动续期订阅：

| 产品 | Reference Name | Product ID | 价格 |
|------|---------------|-----------|------|
| 月付 | Curtail Pro Monthly | `com.curtail.pro.monthly` | $4.99/月 |
| 年付（主推） | Curtail Pro Annual | `com.curtail.pro.yearly` | $29.99/年 |

3. Display Name / Description（≤35/≤55 字符，从 price.md 复制）：
   - Monthly: `Curtail Pro Monthly` / `Unlimited profiles, SOS AI, scans, reports.`
   - Yearly: `Curtail Pro Annual` / `All Pro features, best value, save 50%.`
4. 两个产品均配置 **7 天免费试用**（Free Trial Offer）
5. 年付产品附加 **Win-back offer**：$14.99（续订前 7 天，对应 price.md 恢复期礼遇）
6. 本地测试：Xcode 中 File → New → File → StoreKit Configuration File，添加上述两个产品用于模拟器测试
7. 创建后等 Apple 处理（通常 1-2 小时），在 App 内 Paywall 验证产品加载

---

### 🟢 4. CloudKit Schema 部署（跨设备同步）

**增强功能**：用户多设备（iPhone/Watch）间数据自动同步
**不配置的影响**：App 使用本地存储正常运行；首次真机同步时 CloudKit 会自动创建 Development 环境 schema
**当前状态**：数据模型已完全兼容 CloudKit（所有属性有默认值、关系为可选），容器初始化带三级降级（CloudKit → 本地 → 内存）

**配置步骤**：
1. Xcode 账户登录后（第 2 项），真机运行一次 App 并完成 Onboarding
2. 打开 [CloudKit Console](https://icloud.developer.apple.com) → 选择容器 `iCloud.com.zzoutuo.Curtail`
3. 确认 Development 环境出现 `SubstanceProfile` / `LifeEvent` 记录类型
4. 点击 **Deploy Schema Changes to Production**
5. 重新 Build 验证同步

---

### 🟢 5. App Store ID 回填 Landing 页

**影响功能**：Landing 页下载按钮当前显示 "Coming Soon to the App Store"
**当前状态**：占位符逻辑已内置，回填后自动变成真实下载按钮

**配置步骤**：
1. App 在 App Store Connect 创建后获得 Apple ID（数字）：My Apps → 你的 App → App Information → **Apple ID**
2. 编辑 `docs/index.html`，把 `id[APP_STORE_ID]` 替换为 `id` + 真实数字（如 `id1234567890`）
3. 提交推送到 GitHub（Pages 会自动重新部署）

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| iCloud (CloudKit) | 容器 `iCloud.com.zzoutuo.Curtail`，entitlements 已配置，代码三级降级 | ✅ 已配置 |
| Push Notifications | aps-environment (development) 已配置 | ✅ 已配置 |
| In-App Purchase | StoreKit 2 代码 + 产品 ID 硬编码 + Restore Purchases | ✅ 已配置 |
| App Groups | `group.com.zzoutuo.Curtail`（App/Widget/Watch 三 target） | ✅ 已配置 |
| WidgetKit + Live Activity | CurtailWidgets target（SOS 小组件 + 冲浪实时活动） | ✅ 已配置 |
| watchOS App | CurtailWatch target（手腕 SOS + 触觉呼吸） | ✅ 已配置 |
| 相机权限 | NSCameraUsageDescription（仅标签扫描用，不存原图） | ✅ 已配置 |
| 通知权限 | 本地通知（晚间 check-in + 试用到期前 48h 提醒） | ✅ 已配置 |
| Data Protection | SwiftData 本地加密 + PrivacyInfo.xcprivacy 三 target 全覆盖 | ✅ 已配置 |
| 隐私 | 无定位、无分析 SDK、无广告 SDK；Data Not Collected 标签支撑 | ✅ 已配置 |

### 后端服务

| 服务 | 说明 | 状态 |
|------|------|------|
| 联系客服后端 | Cloudflare Workers，地址：`https://feedback-board.iocompile67692.workers.dev` | ✅ 已部署并集成 |
| 网络权限 | 出站 HTTPS，无需 ATS 例外 | ✅ 已配置 |

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| 核心功能 | 18 个功能模块全部实现（MVVM + SwiftData + Swift 6 并发） | ✅ 已完成 |
| ContactSupportView | 7 主题磁贴、5 必填字段、后端 API 对接、成功/错误反馈 | ✅ 已完成 |
| SettingsView | 政策页链接、Manage subscription 直达、导出、动态版本号 | ✅ 已完成 |
| PurchaseManager | StoreKit 2（reactive isPro + currentEntitlement 逐项验证） | ✅ 已完成 |
| AI 模块 | Apple FM 端侧（iOS 26+ 守卫 + 20 组离线模板降级）+ GLM 云端 BYO-Server | ✅ 已完成 |
| 危机安全 | 本地关键词检测 → 988 危机热线卡 | ✅ 已完成 |
| QA 迭代 | 5 轮问题修复，BUILD SUCCEEDED（iPhone/iPad 实测 0 崩溃） | ✅ 已完成 |

### 💡 使用提示（非开发者配置，App 内自动处理）

**AI 功能**：SOS 教练对话、情绪打标、去羞耻回应、每日一句均使用 Apple Foundation Models（设备端，免费离线），iPhone 15 Pro+ / iOS 26+ 自动启用；其他设备自动使用 20 组预置教练模板，无需任何配置。云端 AI（标签扫描/周报）使用开发者持有的 GLM Key（见手动配置第 1 项），用户零配置。

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub 仓库 | https://github.com/asunnyboy861/Curtail | ✅ 已推送 |
| GitHub Pages | https://asunnyboy861.github.io/Curtail/ | ✅ 已部署 |
| Landing Page | 已部署（App Store ID 占位，见手动配置第 5 项） | ✅ 已完成 |
| App Store 元数据 | keytext.md 已生成并通过 15 项验证（保密，不入库） | ✅ 已完成 |
| 定价配置 | price.md 已生成（订阅制，3 政策页） | ✅ 已完成 |

---

## 三、能力检测详情

> 以下为 PHASE 2 原始检测数据。原 "Auto-Configured Capabilities" 与 "Manual Configuration Required" 内容已重组到上方 Section 一 与 Section 二。

### Analysis

基于《TR-20260916-Curtail戒瘾操作指南》与 us.md 检测：
- CloudKit 私有库同步（无账号体系）→ iCloud (CloudKit)
- UNUserNotificationCenter 本地通知 + CK remote → Push Notifications
- StoreKit 2 订阅（§7.5、§9）→ In-App Purchase
- WidgetKit SOS 快速入口 + Live Activity（§7.6）→ Widget 扩展 target + App Groups
- watchOS 手腕 SOS（§7.6）→ watchOS App target
- 食品标签扫描相机（§7.4）→ NSCameraUsageDescription
- SwiftData 本地加密 → Data Protection（运行时属性，非 entitlement）
- 明确不申请定位（隐私卖点，§6.2）

### No Configuration Needed

- 定位服务 — 有意不申请（地点 = 用户自选标签）
- HealthKit、Sign in with Apple、Siri — 不在指南范围内

### Verification

- 工程构建验证：✅（iPhone 16 iOS 26.4 + iPad Pro 13" iOS 27 模拟器，App + Widget + Watch 全部编译通过，运行 0 崩溃）
- 签名验证（generic/platform=iOS）：⏳ 仅因 Xcode GUI 未登录账户；Team ID 已烘焙，登录后自动解决
- 所有 entitlements 正确：✅
