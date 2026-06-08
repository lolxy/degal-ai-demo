# Plus-UI 前后端系统搭建 — 编码任务列表

> 基于 `spec.md` 需求规格与 `design.md` 架构设计生成，覆盖从环境准备到二次开发就绪验证的完整流程。

---

## 1. 环境检查与准备

### T1.1 检查 JDK 版本
- **前置依赖**：无
- **任务描述**：检查本机是否已安装 JDK 17 或 JDK 21，并验证 JAVA_HOME 环境变量配置正确。若版本不满足要求，列出安装指引。
- **执行步骤**：
  1. 执行 `java -version`，检查输出是否包含 "17" 或 "21"
  2. 执行 `echo %JAVA_HOME%`（Windows）或 `echo $JAVA_HOME`（Linux/Mac），确认环境变量已配置
  3. 若未安装或版本低于 17，提供安装指引：下载 JDK 17/21（推荐 https://adoptium.net/），安装后配置 JAVA_HOME 并将 `%JAVA_HOME%\bin` 加入 PATH
- **验收标准**：`java -version` 输出版本号为 17 或 21，JAVA_HOME 指向正确的 JDK 安装目录

### T1.2 检查 Maven 版本
- **前置依赖**：T1.1
- **任务描述**：检查本机是否已安装 Maven 3.8+，并验证 MAVEN_HOME 环境变量。若未安装，列出安装指引；若已安装但未配置国内镜像源，提供镜像配置指引。
- **执行步骤**：
  1. 执行 `mvn -version`，检查版本号是否 >= 3.8
  2. 检查 `~/.m2/settings.xml` 是否配置了国内镜像源（如华为云镜像）
  3. 若未安装，提供指引：下载 Maven 3.9.x（https://maven.apache.org/download.cgi），解压后配置 MAVEN_HOME 并加入 PATH
  4. 若未配置镜像源，提供配置指引：在 `~/.m2/settings.xml` 中添加华为云镜像 `https://mirrors.huaweicloud.com/repository/maven/`
- **验收标准**：`mvn -version` 输出版本号 >= 3.8，settings.xml 已配置国内镜像源

### T1.3 检查 Node.js 版本
- **前置依赖**：无
- **任务描述**：检查本机是否已安装 Node.js >= 20.19.0。若版本不满足，列出升级指引。
- **执行步骤**：
  1. 执行 `node -v`，检查版本号是否 >= v20.19.0
  2. 若未安装或版本过低，提供指引：下载 Node.js 20.x LTS（https://nodejs.org/），安装后验证
- **验收标准**：`node -v` 输出版本号 >= v20.19.0

### T1.4 检查 npm 版本
- **前置依赖**：T1.3
- **任务描述**：检查 npm 版本是否 >= 8.19.0，并确认已配置国内镜像源。
- **执行步骤**：
  1. 执行 `npm -v`，检查版本号是否 >= 8.19.0
  2. 执行 `npm config get registry`，检查是否已配置国内镜像源
  3. 若未配置，执行 `npm config set registry https://registry.npmmirror.com`
- **验收标准**：`npm -v` 输出版本号 >= 8.19.0，registry 指向 https://registry.npmmirror.com

### T1.5 检查 MySQL 服务状态
- **前置依赖**：无
- **任务描述**：检查本机是否已安装 MySQL 8.0+ 且服务处于运行状态。若未安装或未运行，列出安装/启动指引。
- **执行步骤**：
  1. 执行 `mysql --version`，检查版本号是否 >= 8.0
  2. 执行 `mysql -u root -p -e "SELECT VERSION();"`，验证 MySQL 服务可连接
  3. 若未安装，提供指引：下载 MySQL 8.0（https://dev.mysql.com/downloads/），安装后启动服务
  4. 若服务未运行，提供启动指引：Windows 执行 `net start mysql`，Linux 执行 `systemctl start mysqld`
- **验收标准**：`mysql --version` 输出版本号 >= 8.0，MySQL 服务可正常连接

### T1.6 检查 Redis 服务状态
- **前置依赖**：无
- **任务描述**：检查本机是否已安装 Redis >= 6.0 且服务处于运行状态。若未安装或未运行，列出安装/启动指引。
- **执行步骤**：
  1. 执行 `redis-cli ping`，检查是否返回 PONG
  2. 若返回 PONG，执行 `redis-cli -a ruoyi123 ping` 验证密码是否已设置为 ruoyi123
  3. 若未安装，提供指引：Windows 推荐使用 Memurai 或 WSL 安装 Redis 7.2+；Linux 执行 `apt install redis-server` 或 `yum install redis`
  4. 若服务未运行，提供启动指引：Windows 启动 Memurai/WSL Redis；Linux 执行 `systemctl start redis`
- **验收标准**：`redis-cli -a ruoyi123 ping` 返回 PONG，Redis 版本 >= 6.0，密码为 ruoyi123

### T1.7 检查 Git 版本
- **前置依赖**：无
- **任务描述**：检查本机是否已安装 Git。若未安装，列出安装指引。
- **执行步骤**：
  1. 执行 `git --version`，确认输出版本号
  2. 若未安装，提供指引：下载 Git for Windows（https://git-scm.com/），安装后验证
- **验收标准**：`git --version` 输出有效的 Git 版本号

### T1.8 环境检查汇总报告
- **前置依赖**：T1.1, T1.2, T1.3, T1.4, T1.5, T1.6, T1.7
- **任务描述**：汇总所有环境检查结果，输出检查报告。对不满足要求的项给出明确的安装/配置指引，全部通过后方可继续后续任务。
- **执行步骤**：
  1. 汇总 T1.1 ~ T1.7 的检查结果
  2. 生成环境检查报告，标注每项状态（✅通过 / ❌未通过）
  3. 对未通过项提供详细安装指引链接和步骤
  4. 确认所有项均通过后，标记环境准备完成
- **验收标准**：所有 7 项环境检查均通过，无 ❌ 未通过项

---

## 2. 后端项目克隆与配置

### T2.1 克隆后端项目代码
- **前置依赖**：T1.8
- **任务描述**：从 Gitee 仓库克隆 RuoYi-Vue-Plus 后端项目至本地工作目录。
- **执行步骤**：
  1. 确定项目存放目录（如 `D:\projects\`）
  2. 执行 `git clone https://gitee.com/dromara/RuoYi-Vue-Plus.git`
  3. 进入项目目录，执行 `git log -1` 确认代码已成功克隆
  4. 检查项目根目录是否包含 `pom.xml`、`ruoyi-admin`、`ruoyi-common`、`ruoyi-modules` 等子模块
- **验收标准**：项目目录包含 pom.xml、ruoyi-admin、ruoyi-common、ruoyi-modules 等核心子模块，git log 可正常输出

### T2.2 下载 Maven 依赖并编译
- **前置依赖**：T2.1
- **任务描述**：在后端项目根目录执行 Maven 编译，下载所有依赖并构建项目。
- **执行步骤**：
  1. 在后端项目根目录执行 `mvn clean install -DskipTests`
  2. 观察输出，确认所有模块编译成功
  3. 若出现依赖下载失败，检查 Maven 镜像源配置，或执行 `mvn clean install -DskipTests -U` 强制更新
  4. 确认输出包含 `BUILD SUCCESS`
- **验收标准**：`mvn clean install -DskipTests` 输出 BUILD SUCCESS，无编译错误

### T2.3 验证并修改数据源配置
- **前置依赖**：T2.1, T1.5
- **任务描述**：检查 `application-dev.yml` 中的数据源配置，确保与本地 MySQL 一致（地址、端口、用户名、密码）。
- **执行步骤**：
  1. 打开 `ruoyi-admin/src/main/resources/application-dev.yml`
  2. 检查 `spring.datasource.dynamic.datasource.master.url` 是否为 `jdbc:mysql://localhost:3306/ry-vue?...`
  3. 检查 `spring.datasource.dynamic.datasource.master.username` 是否为 `root`
  4. 检查 `spring.datasource.dynamic.datasource.master.password` 是否与本地 MySQL root 密码一致（默认 `root`）
  5. 若密码不一致，修改 password 为本地 MySQL 实际密码
- **验收标准**：application-dev.yml 中数据源 url 指向 localhost:3306/ry-vue，username 和 password 与本地 MySQL 一致

### T2.4 验证并修改 Redis 配置
- **前置依赖**：T2.1, T1.6
- **任务描述**：检查 `application-dev.yml` 中的 Redis 配置，确保与本地 Redis 一致（地址、端口、密码）。
- **执行步骤**：
  1. 打开 `ruoyi-admin/src/main/resources/application-dev.yml`
  2. 检查 `spring.data.redis.host` 是否为 `localhost`
  3. 检查 `spring.data.redis.port` 是否为 `6379`
  4. 检查 `spring.data.redis.password` 是否为 `ruoyi123`
  5. 若配置不一致，修改为与本地 Redis 服务一致
- **验收标准**：application-dev.yml 中 Redis host 为 localhost、port 为 6379、password 为 ruoyi123

### T2.5 验证 Maven Profile 配置
- **前置依赖**：T2.1
- **任务描述**：确认开发环境使用 `dev` profile 且默认激活。
- **执行步骤**：
  1. 检查 `pom.xml` 中 profiles 配置，确认 `dev` profile 的 `activeByDefault` 为 `true`
  2. 检查 `application.yml` 中 `spring.profiles.active` 是否包含 `dev`
- **验收标准**：dev profile 默认激活，开发环境配置生效

---

## 3. 前端项目克隆与配置

### T3.1 克隆前端项目代码
- **前置依赖**：T1.8
- **任务描述**：从 Gitee 仓库克隆 Plus-UI 前端项目至本地工作目录，使用 ts 分支（稳定发布主分支）。
- **执行步骤**：
  1. 确定项目存放目录（如 `D:\projects\`）
  2. 执行 `git clone https://gitee.com/JavaLionLi/plus-ui.git`
  3. 进入项目目录，执行 `git branch -a` 确认当前分支
  4. 若不在 ts 分支，执行 `git checkout ts`
  5. 检查项目目录是否包含 `package.json`、`src`、`vite.config.ts` 等文件
- **验收标准**：项目目录包含 package.json、src、vite.config.ts 等核心文件，当前在 ts 分支

### T3.2 安装前端依赖
- **前置依赖**：T3.1, T1.3, T1.4
- **任务描述**：使用 npm 安装前端项目所有依赖，推荐使用国内镜像源。
- **执行步骤**：
  1. 在前端项目根目录执行 `npm install --registry=https://registry.npmmirror.com`
  2. 观察输出，确认 `node_modules` 目录生成
  3. 若出现依赖安装失败，尝试执行 `npm cache clean --force` 后重试
  4. 确认无严重错误（warnings 可忽略）
- **验收标准**：node_modules 目录已生成，npm install 无严重错误

### T3.3 验证 Vite 代理配置
- **前置依赖**：T3.1
- **任务描述**：确认 `vite.config.ts` 中 Vite 代理配置正确指向后端 8080 端口。
- **执行步骤**：
  1. 打开 `vite.config.ts`
  2. 检查 `server.proxy` 配置，确认 `/dev-api` 代理目标为 `http://localhost:8080`
  3. 确认 `server.port` 为 `80`
  4. 确认 `server.open` 为 `true`（自动打开浏览器）
  5. 确认 rewrite 规则正确去除 `/dev-api` 前缀
- **验收标准**：vite.config.ts 中 /dev-api 代理目标为 http://localhost:8080，端口为 80，rewrite 规则正确

### T3.4 验证前端环境变量配置
- **前置依赖**：T3.1
- **任务描述**：确认 `.env.development` 中 API 路径和端口配置正确。
- **执行步骤**：
  1. 打开 `.env.development`
  2. 检查 `VITE_APP_BASE_API` 是否为 `/dev-api`
  3. 检查 `VITE_APP_PORT` 是否为 `80`
  4. 检查 `VITE_APP_ENCRYPT` 是否为 `true`
  5. 检查 `VITE_APP_CLIENT_ID` 是否为 `e5cd7e4891bf95d1d19206ce24a7b32e`
- **验收标准**：.env.development 中 VITE_APP_BASE_API=/dev-api，VITE_APP_PORT=80，VITE_APP_ENCRYPT=true，VITE_APP_CLIENT_ID 正确

---

## 4. 数据库初始化

### T4.1 创建 ry-vue 数据库
- **前置依赖**：T1.5
- **任务描述**：在 MySQL 中创建名为 `ry-vue` 的数据库，字符集为 utf8mb4。
- **执行步骤**：
  1. 检查 `ry-vue` 数据库是否已存在：`mysql -u root -p -e "SHOW DATABASES LIKE 'ry-vue';"`
  2. 若已存在，提示用户确认是否备份后删除重建
  3. 执行 `mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS \`ry-vue\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"`
  4. 验证创建成功：`mysql -u root -p -e "SHOW DATABASES LIKE 'ry-vue';"`
- **验收标准**：MySQL 中存在 ry-vue 数据库，字符集为 utf8mb4

### T4.2 执行主库 SQL 脚本
- **前置依赖**：T4.1, T2.1
- **任务描述**：在 ry-vue 数据库中执行 `ry_vue_5.X.sql`，初始化系统核心表结构与数据。
- **执行步骤**：
  1. 确认 SQL 脚本路径：`RuoYi-Vue-Plus/script/sql/ry_vue_5.X.sql`
  2. 执行 `mysql -u root -p ry-vue < script/sql/ry_vue_5.X.sql`
  3. 若执行报错，检查 MySQL 版本是否 >= 8.0，确认字符集为 utf8mb4
  4. 验证核心表已创建：`mysql -u root -p ry-vue -e "SHOW TABLES LIKE 'sys_%';"`
- **验收标准**：sys_user、sys_role、sys_menu、sys_dept、sys_dict_type 等系统表已创建并包含初始数据

### T4.3 执行任务调度 SQL 脚本
- **前置依赖**：T4.2
- **任务描述**：在 ry-vue 数据库中执行 `ry_job.sql`，初始化 SnailJob 任务调度相关表。
- **执行步骤**：
  1. 确认 SQL 脚本路径：`RuoYi-Vue-Plus/script/sql/ry_job.sql`
  2. 执行 `mysql -u root -p ry-vue < script/sql/ry_job.sql`
  3. 验证任务调度表已创建：`mysql -u root -p ry-vue -e "SHOW TABLES LIKE 'sj_%';"`
- **验收标准**：sj_group_config、sj_job 等任务调度表已创建

### T4.4 执行工作流 SQL 脚本
- **前置依赖**：T4.3
- **任务描述**：在 ry-vue 数据库中执行 `ry_workflow.sql`，初始化 Flowable 工作流相关表。
- **执行步骤**：
  1. 确认 SQL 脚本路径：`RuoYi-Vue-Plus/script/sql/ry_workflow.sql`
  2. 执行 `mysql -u root -p ry-vue < script/sql/ry_workflow.sql`
  3. 验证工作流表已创建：`mysql -u root -p ry-vue -e "SHOW TABLES LIKE 'flow_%';"`
- **验收标准**：flow_definition、flow_instance 等工作流表已创建

### T4.5 验证数据库初始化结果
- **前置依赖**：T4.4
- **任务描述**：验证数据库初始化完整性，确认默认管理员账号存在。
- **执行步骤**：
  1. 执行 `mysql -u root -p ry-vue -e "SELECT user_name FROM sys_user WHERE user_id = 1;"` 确认 admin 用户存在
  2. 执行 `mysql -u root -p ry-vue -e "SHOW TABLES;"` 统计表数量，确认核心表、任务调度表、工作流表均存在
  3. 验证初始数据完整性（角色、菜单、字典等）
- **验收标准**：sys_user 表中存在 admin 用户，所有核心表、任务调度表、工作流表均已创建

---

## 5. Redis 配置

### T5.1 配置 Redis 密码
- **前置依赖**：T1.6
- **任务描述**：确保 Redis 服务密码设置为 `ruoyi123`，与后端配置保持一致。
- **执行步骤**：
  1. 执行 `redis-cli -a ruoyi123 ping`，验证密码是否已生效
  2. 若返回 `(error) NOAUTH Authentication required`，说明密码已设置但可能不是 ruoyi123，需修改 redis.conf 中 `requirepass` 为 `ruoyi123`
  3. 若无需密码即可连接，说明未设置密码，需修改 redis.conf 添加 `requirepass ruoyi123`
  4. 修改配置后重启 Redis 服务
- **验收标准**：`redis-cli -a ruoyi123 ping` 返回 PONG，`redis-cli ping` 返回 NOAUTH 错误（确认密码生效）

### T5.2 验证 Redis 端口与连接
- **前置依赖**：T5.1
- **任务描述**：验证 Redis 监听端口为 6379，且后端配置与 Redis 服务配置一致。
- **执行步骤**：
  1. 执行 `redis-cli -a ruoyi123 -p 6379 ping`，确认端口 6379 可连接
  2. 检查 redis.conf 中 `port` 配置是否为 6379
  3. 确认后端 application-dev.yml 中 Redis 配置（host/port/password）与 Redis 服务一致
- **验收标准**：Redis 监听 6379 端口，后端配置与 Redis 服务配置完全一致

---

## 6. 后端启动与验证

### T6.1 启动后端服务
- **前置依赖**：T2.2, T2.3, T2.4, T4.5, T5.2
- **任务描述**：通过 Maven 命令或 IDE 启动 RuoYiApplication 主类，启动后端服务。
- **执行步骤**：
  1. 在后端项目根目录执行 `mvn spring-boot:run -pl ruoyi-admin`
  2. 或在 IDE 中运行 `ruoyi-admin/src/main/java/org/dromara/RuoYiApplication.java` 主类
  3. 观察启动日志，等待出现 "Application RuoYi-Vue-Plus is running!" 提示
  4. 若启动失败，检查日志中的 ERROR 信息，按异常场景排查（数据库连接/Redis连接/端口占用/依赖缺失）
- **验收标准**：后端服务启动成功，监听 8080 端口，启动日志包含 "Application RuoYi-Vue-Plus is running!"

### T6.2 后端健康检查
- **前置依赖**：T6.1
- **任务描述**：验证后端健康检查接口可正常响应。
- **执行步骤**：
  1. 执行 `curl http://localhost:8080/actuator/health` 或浏览器访问该地址
  2. 确认返回 HTTP 200，且 `status` 为 `UP`
- **验收标准**：http://localhost:8080/actuator/health 返回 {"status":"UP"}

### T6.3 验证接口文档访问
- **前置依赖**：T6.1
- **任务描述**：验证 Swagger/Knife4j 接口文档页面可正常访问。
- **执行步骤**：
  1. 浏览器访问 `http://localhost:8080/doc.html`
  2. 确认页面正常加载，显示 Knife4j 接口文档界面
- **验收标准**：http://localhost:8080/doc.html 正常显示接口文档页面

### T6.4 检查后端启动日志
- **前置依赖**：T6.1
- **任务描述**：检查后端启动日志，确认无 ERROR 级别异常。
- **执行步骤**：
  1. 查看后端控制台输出或 `./logs/` 目录下的日志文件
  2. 搜索 `ERROR` 关键字，确认无严重异常
  3. 确认日志中包含 "Application RuoYi-Vue-Plus is running!" 启动成功标识
- **验收标准**：启动日志无 ERROR 异常，包含启动成功标识

---

## 7. 前端启动与验证

### T7.1 启动前端开发服务
- **前置依赖**：T3.2, T3.3, T3.4
- **任务描述**：通过 `npm run dev` 启动 Vite 前端开发服务。
- **执行步骤**：
  1. 在前端项目根目录执行 `npm run dev`
  2. 观察控制台输出，确认 Vite 开发服务启动成功
  3. 确认浏览器自动打开 `http://localhost:80`
  4. 若端口 80 被占用，修改 `.env.development` 中 `VITE_APP_PORT` 为其他端口
- **验收标准**：Vite 开发服务启动成功，监听 80 端口，浏览器自动打开

### T7.2 验证前端页面加载
- **前置依赖**：T7.1
- **任务描述**：验证前端登录页面可正常访问和显示。
- **执行步骤**：
  1. 浏览器访问 `http://localhost:80`
  2. 确认页面正常加载，显示 RuoYi-Vue-Plus 多租户管理系统登录页面
  3. 确认验证码图片正常显示（数学计算型验证码）
  4. 确认页面无白屏或 JS 错误
- **验收标准**：http://localhost:80 显示登录页面，验证码正常加载，无 JS 错误

### T7.3 验证前端编译无错误
- **前置依赖**：T7.1
- **任务描述**：确认 Vite 启动后控制台无编译错误。
- **执行步骤**：
  1. 检查 Vite 控制台输出，确认无红色 ERROR 信息
  2. 打开浏览器 DevTools Console，确认无 TypeScript 编译错误
- **验收标准**：Vite 控制台和浏览器 Console 无编译错误

---

## 8. 联调验证

### T8.1 验证 API 代理转发
- **前置依赖**：T6.1, T7.2
- **任务描述**：验证前端 API 请求通过 Vite 代理正确转发至后端 8080 端口。
- **执行步骤**：
  1. 在前端登录页面打开浏览器 DevTools Network 面板
  2. 刷新页面，观察验证码请求路径是否为 `/dev-api/captchaImage`
  3. 点击该请求，确认其被代理转发至 `http://localhost:8080/captchaImage`
  4. 确认响应数据正常返回
- **验收标准**：/dev-api 请求被正确代理至 localhost:8080，响应数据正常

### T8.2 管理员登录验证
- **前置依赖**：T8.1
- **任务描述**：使用默认管理员账号登录系统，验证前后端联调正常。
- **执行步骤**：
  1. 在登录页面输入用户名 `admin`、密码 `admin123`
  2. 输入验证码（数学计算结果）
  3. 点击登录按钮
  4. 观察 Network 面板，确认 `/dev-api/auth/login` 请求成功返回 Token
  5. 确认登录成功后跳转至系统首页
- **验收标准**：admin/admin123 + 验证码登录成功，跳转至系统首页，Token 正确存储

### T8.3 验证菜单加载
- **前置依赖**：T8.2
- **任务描述**：验证登录成功后系统菜单正常加载。
- **执行步骤**：
  1. 登录成功后，观察左侧菜单栏
  2. 确认菜单正常显示：系统管理、系统监控、系统工具等菜单项
  3. 确认菜单图标和文字正常渲染
- **验收标准**：左侧菜单栏正常显示系统管理、系统监控、系统工具等菜单项

### T8.4 验证业务数据交互
- **前置依赖**：T8.3
- **任务描述**：验证前后端数据交互正常，执行系统管理操作确认数据正常返回。
- **执行步骤**：
  1. 点击 系统管理 → 用户管理，确认用户列表数据正常显示
  2. 点击 系统管理 → 角色管理，确认角色列表数据正常显示
  3. 点击 系统管理 → 菜单管理，确认菜单树正常显示
  4. 点击 系统监控 → 在线用户，确认在线用户列表正常显示
- **验收标准**：用户列表、角色列表、菜单树、在线用户列表数据均正常返回并渲染

---

## 9. 二次开发就绪验证

### T9.1 验证后端项目结构完整性
- **前置依赖**：T2.2
- **任务描述**：验证后端项目包含所有核心模块，结构完整。
- **执行步骤**：
  1. 检查项目目录是否包含：ruoyi-admin、ruoyi-common、ruoyi-modules、ruoyi-extend
  2. 检查 ruoyi-modules 下是否包含：ruoyi-system、ruoyi-generator、ruoyi-job、ruoyi-demo、ruoyi-workflow
  3. 检查 ruoyi-common 下是否包含核心子模块（core、log、security、redis、mybatis、satoken 等）
- **验收标准**：后端项目包含所有核心模块和子模块，结构完整

### T9.2 验证前端项目结构完整性
- **前置依赖**：T3.2
- **任务描述**：验证前端项目包含所有核心目录，结构完整。
- **执行步骤**：
  1. 检查 src 目录下是否包含：api、views、components、store、router、utils、plugins
  2. 检查项目根目录是否包含：public、vite.config.ts、package.json、tsconfig.json
  3. 检查 .env.development 环境变量文件是否存在
- **验收标准**：前端项目包含所有核心目录和配置文件，结构完整

### T9.3 后端编译验证
- **前置依赖**：T2.2
- **任务描述**：验证后端代码可通过 Maven 编译无错误，确认二次开发可编译。
- **执行步骤**：
  1. 在后端项目根目录执行 `mvn compile`
  2. 确认输出 `BUILD SUCCESS`
- **验收标准**：`mvn compile` 输出 BUILD SUCCESS

### T9.4 前端构建验证
- **前置依赖**：T3.2
- **任务描述**：验证前端代码可通过生产构建无错误，确认二次开发可构建。
- **执行步骤**：
  1. 在前端项目根目录执行 `npm run build:prod`
  2. 确认构建成功，`dist` 目录生成
  3. 确认构建过程无 TypeScript 类型错误
- **验收标准**：`npm run build:prod` 构建成功，dist 目录生成，无类型错误

### T9.5 代码生成器功能验证
- **前置依赖**：T8.2
- **任务描述**：验证后端代码生成器功能可用，支持二次开发代码生成。
- **执行步骤**：
  1. 登录系统，进入 系统工具 → 代码生成
  2. 点击"导入"按钮，选择数据库表进行导入
  3. 确认表导入成功
  4. 点击"生成代码"按钮，确认代码可正常预览或下载
- **验收标准**：代码生成器可正常导入表并生成代码

### T9.6 二次开发就绪综合验证
- **前置依赖**：T9.1, T9.2, T9.3, T9.4, T9.5, T8.4
- **任务描述**：综合验证所有二次开发就绪条件，输出最终验证报告。
- **执行步骤**：
  1. 汇总 T9.1 ~ T9.5 的验证结果
  2. 确认前后端项目结构完整
  3. 确认前后端代码均可编译/构建
  4. 确认前后端联调正常，业务功能可用
  5. 确认代码生成器可用
  6. 输出二次开发就绪验证报告，标注每项状态（✅通过 / ❌未通过）
- **验收标准**：所有验证项均通过，项目处于二次开发就绪状态