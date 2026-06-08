---
name: ruoyi-vue-plus-setup
description: 搭建 RuoYi-Vue-Plus 前后端分离管理系统开发环境，包含环境检查、项目克隆、数据库初始化、服务启动与联调验证全流程
triggers:
  - 搭建ruoyi
  - 部署ruoyi-vue-plus
  - 启动plus-ui
  - 搭建前后端管理系统
---

# RuoYi-Vue-Plus 前后端系统搭建技能

## 适用场景

当用户需要搭建 RuoYi-Vue-Plus + Plus-UI 前后端分离管理系统开发环境时使用此技能。

## 前置条件

- Windows 11 操作系统
- 管理员权限（部分操作需要）

## 环境要求

| 软件 | 最低版本 | 推荐版本 | 下载地址 |
|------|----------|----------|----------|
| JDK | 17 | 21 | https://adoptium.net/ |
| Maven | 3.8 | 3.9.x | https://maven.apache.org/download.cgi |
| Node.js | 20.19.0 | 22.x LTS | https://nodejs.org/ |
| MySQL | 8.0 | 8.0.x | https://dev.mysql.com/downloads/ |
| Redis | 6.0 | 7.2+ | Windows: Memurai 或 WSL |
| Git | 2.x | 最新 | https://git-scm.com/ |

## 项目信息

| 项目 | 仓库 | 默认端口 |
|------|------|----------|
| 后端 RuoYi-Vue-Plus | https://gitee.com/dromara/RuoYi-Vue-Plus.git | 8080 |
| 前端 Plus-UI | https://gitee.com/JavaLionLi/plus-ui.git (ts分支) | 80/8081 |

## 执行流程

### 阶段1：环境检查与准备

1. 并行检查所有软件版本：
   ```powershell
   java -version    # 需要 17 或 21+
   mvn -version     # 需要 3.8+
   node -v          # 需要 20.19.0+
   npm -v           # 需要 8.19.0+
   mysql --version  # 需要 8.0+
   redis-cli ping   # 需要返回 PONG
   git --version    # 任意版本
   ```
2. 检查npm镜像：`npm config get registry`，未配置则执行 `npm config set registry https://registry.npmmirror.com`
3. 检查Maven镜像：确认 `~/.m2/settings.xml` 配置了国内镜像（阿里云 `https://maven.aliyun.com/repository/public`）
4. 输出环境检查报告，标注每项 ✅/❌

### 阶段2：项目克隆

1. 创建项目目录（如 `D:\projects\`）
2. 克隆后端：`git clone https://gitee.com/dromara/RuoYi-Vue-Plus.git`
3. 克隆前端：`git clone https://gitee.com/JavaLionLi/plus-ui.git`
4. 前端切换到ts分支：`git checkout ts`

### 阶段3：配置修改

1. **后端数据源配置**：修改 `ruoyi-admin/src/main/resources/application-dev.yml`
   - `spring.datasource.dynamic.datasource.master.password` 改为实际MySQL root密码
   - Redis配置默认 `localhost:6379`，密码 `ruoyi123`，通常无需修改

2. **后端日志配置**：修改 `ruoyi-admin/src/main/resources/logback-plus.xml`
   - `log.path` 从 `./logs` 改为绝对路径（如 `D:/projects/RuoYi-Vue-Plus/logs`）
   - 避免相对路径权限问题

3. **前端端口配置**：修改 `.env.development`
   - `VITE_APP_PORT` 从 `80` 改为 `8081`（Windows 80端口需管理员权限）

4. **Redis密码**：执行 `redis-cli CONFIG SET requirepass "ruoyi123"`
   - 持久化需修改 redis.windows-service.conf 添加 `requirepass ruoyi123`

5. **Maven镜像**：如私有仓库不可达，修改 `~/.m2/settings.xml` 使用阿里云镜像

### 阶段4：数据库初始化

1. 创建数据库：`CREATE DATABASE IF NOT EXISTS ry-vue CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;`
2. 按顺序执行SQL脚本：
   - `mysql -u root -p ry-vue < script/sql/ry_vue_5.X.sql`
   - `mysql -u root -p ry-vue < script/sql/ry_job.sql`
   - `mysql -u root -p ry-vue < script/sql/ry_workflow.sql`
3. 验证：确认59张表创建成功，admin用户存在

### 阶段5：编译与启动

1. **后端编译**：`mvn clean install -DskipTests -T 4`（并行编译加速）
2. **前端依赖**：`npm install --registry=https://registry.npmmirror.com`
3. **后端启动**：`java -jar ruoyi-admin/target/ruoyi-admin.jar`（工作目录为项目根目录）
4. **前端启动**：`npm run dev`
5. 等待后端启动完成（约60-130秒），确认8080端口监听

### 阶段6：联调验证

1. 访问前端页面 `http://localhost:8081`
2. 使用 `admin / admin123` + 验证码登录
3. 确认菜单正常加载、数据正常显示

## 启动脚本

### 后端启动脚本 (start-backend.bat)

```bat
@echo off
chcp 65001 >nul 2>&1
title RuoYi-Vue-Plus Backend Server
set JAVA_HOME=<JDK路径>
set MAVEN_HOME=<Maven路径>
set PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin%;%PATH%
cd /d "%~dp0"
if not exist "ruoyi-admin\target\ruoyi-admin.jar" (
    call mvn clean package -DskipTests -pl ruoyi-admin -am -T 4
)
java -jar ruoyi-admin\target\ruoyi-admin.jar
pause
```

### 前端启动脚本 (start-frontend.bat)

```bat
@echo off
chcp 65001 >nul 2>&1
title Plus-UI Frontend Dev Server
cd /d "%~dp0"
if not exist "node_modules" (
    call npm install --registry=https://registry.npmmirror.com
)
call npm run dev
pause
```

## 常见问题排查

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| Logback配置错误 | 日志目录无写入权限 | 修改logback-plus.xml中log.path为绝对路径 |
| Maven依赖下载失败 | 私有仓库不可达 | 切换settings.xml镜像为阿里云公共仓库 |
| 80端口启动失败 | 需管理员权限 | 修改.env.development中VITE_APP_PORT为8081 |
| Redis NOAUTH | 密码未设置 | 执行redis-cli CONFIG SET requirepass "ruoyi123" |
| 后端启动超时 | 正常现象 | 等待60-130秒，查看日志确认启动完成 |
| vite命令找不到 | node_modules未安装 | 执行npm install --registry=https://registry.npmmirror.com |
| SQL执行编码错误 | 字符集不匹配 | 添加--default-character-set=utf8mb4参数 |

## 默认账号与配置

| 配置项 | 值 |
|--------|-----|
| 管理员用户名 | admin |
| 管理员密码 | admin123 |
| 数据库名 | ry-vue |
| Redis密码 | ruoyi123 |
| 后端端口 | 8080 |
| 前端端口 | 8081 |
| API文档 | http://localhost:8080/doc.html |