# **1. 实现模型**

## **1.1 上下文视图**

### 系统整体架构

本系统采用前后端分离架构，前端通过Vite开发代理转发API请求至后端，后端连接MySQL与Redis提供业务服务。

```plantuml
@startuml
!theme plain
skinparam componentStyle rectangle

actor "开发者" as dev

package "前端层 (Plus-UI)" as frontend {
    component [Vue 3.5 + TypeScript\nElement Plus + Vite 7.3\nPinia 状态管理] as vue
    component [Vite Dev Server\n端口80\n代理 /dev-api → 8080] as vite
}

package "后端层 (RuoYi-Vue-Plus)" as backend {
    component [Spring Boot 3.5\nUndertow 容器\n端口8080] as springboot
    component [Sa-Token\n权限认证] as satoken
    component [MyBatis-Plus\nORM + 多租户] as mybatis
    component [Redisson\n分布式锁/限流] as redisson
    component [HikariCP\n连接池] as hikari
}

database "MySQL 8.0+\nry-vue 库\n端口3306" as mysql
database "Redis 7.2+\n端口6379\n密码ruoyi123" as redis

dev --> vue : http://localhost:80
vue --> vite : 页面请求
vite --> springboot : API代理 /dev-api → :8080
springboot --> satoken : 认证鉴权
springboot --> mybatis : 数据持久化
mybatis --> hikari : 连接管理
hikari --> mysql : JDBC localhost:3306/ry-vue
springboot --> redisson : 缓存/锁/限流
redisson --> redis : Redis协议 localhost:6379

@enduml
```

### 部署拓扑视图

```plantuml
@startuml
!theme plain

node "开发者本地机器" as local {
    component [浏览器\nhttp://localhost:80] as browser
    component [Vite Dev Server\n:80] as vite
    component [RuoYiApplication\n:8080] as backend
    database [MySQL\n:3306] as mysql
    database [Redis\n:6379] as redis
}

browser --> vite : HTTP
vite --> backend : 代理转发 /dev-api
backend --> mysql : JDBC
backend --> redis : Redisson

@enduml
```

## **1.2 服务/组件总体架构**

### 后端模块架构

```plantuml
@startuml
!theme plain

package "RuoYi-Vue-Plus" as root {
    package "ruoyi-admin" as admin {
        [RuoYiApplication\n启动入口]
        [application-dev.yml\n开发环境配置]
        [application.yml\n主配置]
    }

    package "ruoyi-common" as common {
        [ruoyi-common-core\n核心工具类]
        [ruoyi-common-log\n操作日志]
        [ruoyi-common-security\n安全配置]
        [ruoyi-common-redis\nRedis配置]
        [ruoyi-common-mybatis\nMyBatis配置]
        [ruoyi-common-doc\n接口文档]
        [ruoyi-common-encrypt\n加解密]
        [ruoyi-common-translation\n翻译]
        [ruoyi-common-satoken\nSa-Token集成]
        [ruoyi-common-mail\n邮件]
        [ruoyi-common-oss\n对象存储]
        [ruoyi-common-json\nJSON处理]
    }

    package "ruoyi-modules" as modules {
        package "ruoyi-system" as system {
            [用户/角色/菜单\n部门/岗位管理]
        }
        package "ruoyi-generator" as generator {
            [代码生成器]
        }
        package "ruoyi-job" as job {
            [任务调度(SnailJob)]
        }
        package "ruoyi-workflow" as workflow {
            [工作流(Flowable)]
        }
        package "ruoyi-demo" as demo {
            [功能演示模块]
        }
    }

    package "ruoyi-extend" as extend {
        [扩展功能模块]
    }
}

admin --> common : 依赖
admin --> modules : 依赖
admin --> extend : 依赖
modules --> common : 依赖

@enduml
```

### 前端模块架构

```plantuml
@startuml
!theme plain

package "Plus-UI" as root {
    package "src" as src {
        package "api" as api {
            [后端接口封装\nAxios请求层]
        }
        package "views" as views {
            [页面组件\n登录/系统管理/监控等]
        }
        package "components" as components {
            [公共组件\n表格/表单/对话框等]
        }
        package "store" as store {
            [Pinia状态管理\n用户/权限/应用]
        }
        package "router" as router {
            [Vue Router\n动态路由]
        }
        package "utils" as utils {
            [工具函数\n请求/加密/验证等]
        }
        package "plugins" as plugins {
            [插件配置\nElement Plus等]
        }
    }

    component [vite.config.ts\nVite配置\n代理/构建] as vite
    component [.env.development\n开发环境变量] as env
    component [package.json\n依赖管理] as pkg
}

views --> api : 调用接口
views --> components : 使用组件
views --> store : 读写状态
router --> store : 获取权限
api --> utils : 请求封装

@enduml
```

## **1.3 实现设计文档**

### 1.3.1 环境准备方案

#### 软件清单与版本约束

| 软件 | 最低版本 | 推荐版本 | 验证命令 | 用途 |
|------|---------|---------|---------|------|
| JDK | 17 | 17 或 21 | `java -version` | 后端编译运行 |
| Maven | 3.8 | 3.9.x | `mvn -version` | 后端构建 |
| Node.js | 20.19.0 | 20.x LTS | `node -v` | 前端运行时 |
| npm | 8.19.0 | 10.x | `npm -v` | 前端包管理 |
| MySQL | 8.0 | 8.0.x | `mysql --version` | 业务数据存储 |
| Redis | 6.0 | 7.2+ | `redis-cli ping` | 缓存/会话/锁 |
| Git | 任意稳定版 | 2.x | `git --version` | 代码版本控制 |

#### 环境安装步骤

**步骤1：JDK安装与配置**

```bash
# Windows: 下载并安装JDK 17或21
# 配置JAVA_HOME环境变量指向JDK安装目录
# 将%JAVA_HOME%\bin添加到PATH

# 验证
java -version
# 预期输出包含 "17" 或 "21"
```

**步骤2：Maven安装与配置**

```bash
# Windows: 下载Maven 3.9.x并解压
# 配置MAVEN_HOME环境变量
# 将%MAVEN_HOME%\bin添加到PATH

# 配置国内镜像源（settings.xml）
# 在 ~/.m2/settings.xml 中添加：
# <mirror>
#   <id>huaweicloud</id>
#   <url>https://mirrors.huaweicloud.com/repository/maven/</url>
#   <mirrorOf>*</mirrorOf>
# </mirror>

# 验证
mvn -version
```

**步骤3：Node.js安装**

```bash
# Windows: 下载Node.js 20.x LTS安装包
# npm随Node.js一同安装

# 配置npm国内镜像
npm config set registry https://registry.npmmirror.com

# 验证
node -v   # 预期 >= v20.19.0
npm -v    # 预期 >= 8.19.0
```

**步骤4：MySQL安装与启动**

```bash
# Windows: 下载MySQL 8.0安装包，安装后启动服务
# 默认账号: root/root

# 验证
mysql --version
mysql -u root -p -e "SELECT VERSION();"
```

**步骤5：Redis安装与启动**

```bash
# Windows: 下载Redis for Windows或使用WSL
# 修改redis.conf设置密码：
# requirepass ruoyi123

# 启动Redis服务
redis-server redis.conf

# 验证
redis-cli -a ruoyi123 ping
# 预期返回 PONG
```

**步骤6：Git安装**

```bash
# Windows: 下载Git for Windows安装
git --version
```

#### 环境检查脚本逻辑

```plantuml
@startuml
start
:检查 java -version;
if (版本 >= 17?) then (是)
else (否)
  :提示安装JDK 17/21;
  :终止;
endif
:检查 mvn -version;
if (版本 >= 3.8?) then (是)
else (否)
  :提示安装Maven 3.8+;
  :终止;
endif
:检查 node -v;
if (版本 >= 20.19.0?) then (是)
else (否)
  :提示升级Node.js;
  :终止;
endif
:检查 MySQL服务状态;
if (MySQL运行中?) then (是)
else (否)
  :提示启动MySQL;
  :终止;
endif
:检查 Redis服务状态;
if (Redis运行中?) then (是)
else (否)
  :提示启动Redis;
  :终止;
endif
:环境检查通过;
stop
@enduml
```

### 1.3.2 后端项目搭建方案

#### 代码克隆

```bash
# 克隆后端项目
git clone https://gitee.com/dromara/RuoYi-Vue-Plus.git
cd RuoYi-Vue-Plus
```

#### 关键配置文件修改

**application-dev.yml 数据源配置**

```yaml
# 文件路径: ruoyi-admin/src/main/resources/application-dev.yml
spring:
  datasource:
    dynamic:
      datasource:
        master:
          url: jdbc:mysql://localhost:3306/ry-vue?useUnicode=true&characterEncoding=utf8mb4&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8&autoReconnect=true&rewriteBatchedStatements=true
          username: root
          password: root  # 修改为本地MySQL密码
```

**application-dev.yml Redis配置**

```yaml
# 文件路径: ruoyi-admin/src/main/resources/application-dev.yml
spring:
  data:
    redis:
      host: localhost
      port: 6379
      password: ruoyi123  # 与Redis服务密码保持一致
      database: 0
```

#### Maven编译

```bash
# 在项目根目录执行
mvn clean install -DskipTests
# 预期输出: BUILD SUCCESS
```

#### 后端启动

```bash
# 方式1: Maven命令启动
mvn spring-boot:run -pl ruoyi-admin

# 方式2: IDE中运行 RuoYiApplication 主类
# 主类路径: ruoyi-admin/src/main/java/org/dromara/RuoYiApplication.java
```

#### 后端启动验证

```bash
# 健康检查
curl http://localhost:8080/actuator/health
# 预期: {"status":"UP"}

# 接口文档
# 浏览器访问: http://localhost:8080/doc.html

# 启动日志检查
# 预期包含: "Application RuoYi-Vue-Plus is running!"
```

### 1.3.3 前端项目搭建方案

#### 代码克隆

```bash
# 克隆前端项目（默认ts分支）
git clone https://gitee.com/JavaLionLi/plus-ui.git
cd plus-ui
```

#### 依赖安装

```bash
# 使用国内镜像安装依赖
npm install --registry=https://registry.npmmirror.com
# 预期: node_modules目录生成，无严重错误
```

#### 关键配置文件验证

**vite.config.ts 代理配置**

```typescript
// 文件路径: vite.config.ts
// 确认server.proxy配置如下：
server: {
  port: 80,  // 前端开发服务端口
  host: true,
  open: true,
  proxy: {
    '/dev-api': {
      target: 'http://localhost:8080',  // 后端服务地址
      changeOrigin: true,
      rewrite: (p) => p.replace(/^\/dev-api/, '')
    }
  }
}
```

**.env.development 环境变量**

```bash
# 文件路径: .env.development
VITE_APP_BASE_API = '/dev-api'
VITE_APP_PORT = 80
VITE_APP_ENCRYPT = true
VITE_APP_CLIENT_ID = e5cd7e4891bf95d1d19206ce24a7b32e
```

#### 前端启动

```bash
# 启动Vite开发服务
npm run dev
# 预期: 浏览器自动打开 http://localhost:80
```

#### 前端启动验证

```bash
# 页面访问验证
# 浏览器访问 http://localhost:80
# 预期: 显示RuoYi-Vue-Plus多租户管理系统登录页面

# API代理验证
# 在浏览器DevTools Network面板观察
# 登录操作的请求路径应为 /dev-api/auth/login
# 代理转发至 http://localhost:8080/auth/login
```

### 1.3.4 数据库初始化方案

#### 初始化流程

```plantuml
@startuml
start
:连接MySQL;
:创建数据库 ry-vue\n字符集utf8mb4;
:执行 ry_vue_5.X.sql\n(系统表结构与初始数据);
:执行 ry_job.sql\n(SnailJob任务调度表);
:执行 ry_workflow.sql\n(Flowable工作流表);
:验证 sys_user 表存在admin用户;
:数据库初始化完成;
stop
@enduml
```

#### 具体步骤

```bash
# 步骤1: 创建数据库
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS \`ry-vue\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

# 步骤2: 执行主库SQL（在RuoYi-Vue-Plus项目目录下）
mysql -u root -p ry-vue < script/sql/ry_vue_5.X.sql

# 步骤3: 执行任务调度SQL
mysql -u root -p ry-vue < script/sql/ry_job.sql

# 步骤4: 执行工作流SQL
mysql -u root -p ry-vue < script/sql/ry_workflow.sql

# 步骤5: 验证初始化结果
mysql -u root -p ry-vue -e "SHOW TABLES;"
mysql -u root -p ry-vue -e "SELECT user_name FROM sys_user WHERE user_id = 1;"
# 预期: admin
```

#### SQL脚本执行顺序约束

| 顺序 | SQL脚本 | 说明 | 关键表 |
|------|---------|------|--------|
| 1 | ry_vue_5.X.sql | 系统核心表结构与数据 | sys_user, sys_role, sys_menu, sys_dept, sys_dict_type 等 |
| 2 | ry_job.sql | SnailJob任务调度表 | sj_group_config, sj_job 等 |
| 3 | ry_workflow.sql | Flowable工作流表 | flow_definition, flow_instance 等 |

### 1.3.5 Redis配置方案

#### 配置步骤

```bash
# 步骤1: 修改redis.conf配置文件
# 找到redis.conf文件，修改以下配置：
# requirepass ruoyi123
# port 6379

# 步骤2: 启动Redis服务（使用配置文件）
redis-server /path/to/redis.conf

# 步骤3: 验证Redis连接
redis-cli -a ruoyi123 ping
# 预期返回: PONG

# 步骤4: 验证密码认证
redis-cli ping
# 预期返回: (error) NOAUTH Authentication required
# （确认密码已生效）
```

#### Redis与后端配置一致性校验

| 配置项 | Redis服务端 (redis.conf) | 后端 (application-dev.yml) | 默认值 |
|--------|--------------------------|---------------------------|--------|
| host | bind 127.0.0.1 | spring.data.redis.host | localhost |
| port | port 6379 | spring.data.redis.port | 6379 |
| password | requirepass ruoyi123 | spring.data.redis.password | ruoyi123 |

### 1.3.6 联调验证方案

#### 联调验证流程

```plantuml
@startuml
start
:启动MySQL服务;
:启动Redis服务;
:启动后端服务(RuoYiApplication);
if (后端健康检查通过?) then (是)
else (否)
  :排查后端启动日志;
  :终止;
endif
:启动前端服务(npm run dev);
:浏览器访问 http://localhost:80;
if (登录页面正常显示?) then (是)
else (否)
  :排查前端编译错误;
  :终止;
endif
:输入 admin/admin123 + 验证码;
:点击登录;
if (登录成功?) then (是)
else (否)
  :排查API代理与后端接口;
  :终止;
endif
:验证菜单加载;
:执行系统管理操作;
if (数据正常返回?) then (是)
else (否)
  :排查前后端数据交互;
  :终止;
endif
:联调验证通过;
stop
@enduml
```

#### 验证检查清单

| 序号 | 验证项 | 操作方式 | 预期结果 |
|------|--------|---------|---------|
| 1 | 后端健康检查 | `curl http://localhost:8080/actuator/health` | `{"status":"UP"}` |
| 2 | 接口文档访问 | 浏览器访问 `http://localhost:8080/doc.html` | 显示Knife4j接口文档页面 |
| 3 | 前端页面加载 | 浏览器访问 `http://localhost:80` | 显示登录页面 |
| 4 | 验证码获取 | 登录页自动加载 | 显示数学计算验证码 |
| 5 | 管理员登录 | 输入admin/admin123+验证码 | 登录成功跳转首页 |
| 6 | 菜单加载 | 登录后观察左侧菜单 | 系统管理/系统监控等菜单正常 |
| 7 | 用户列表查询 | 系统管理→用户管理 | 用户列表数据正常显示 |
| 8 | API代理转发 | DevTools Network面板 | `/dev-api`请求代理至8080 |

### 1.3.7 二次开发就绪验证方案

#### 项目结构完整性验证

**后端项目结构**

```
RuoYi-Vue-Plus/
├── ruoyi-admin/          # 启动模块（RuoYiApplication）
├── ruoyi-common/         # 公共模块
│   ├── ruoyi-common-core/
│   ├── ruoyi-common-log/
│   ├── ruoyi-common-security/
│   ├── ruoyi-common-redis/
│   ├── ruoyi-common-mybatis/
│   ├── ruoyi-common-doc/
│   ├── ruoyi-common-encrypt/
│   ├── ruoyi-common-satoken/
│   └── ...
├── ruoyi-modules/        # 业务模块
│   ├── ruoyi-system/     # 系统管理
│   ├── ruoyi-generator/  # 代码生成
│   ├── ruoyi-job/        # 任务调度
│   ├── ruoyi-workflow/   # 工作流
│   └── ruoyi-demo/       # 演示模块
├── ruoyi-extend/         # 扩展模块
├── script/               # 脚本文件
│   └── sql/              # SQL初始化脚本
└── pom.xml               # Maven父POM
```

**前端项目结构**

```
plus-ui/
├── src/
│   ├── api/              # 后端接口封装
│   ├── views/            # 页面组件
│   ├── components/       # 公共组件
│   ├── store/            # Pinia状态管理
│   ├── router/           # 路由配置
│   ├── utils/            # 工具函数
│   ├── plugins/          # 插件配置
│   └── ...
├── public/               # 静态资源
├── vite.config.ts        # Vite配置
├── .env.development      # 开发环境变量
├── package.json          # 依赖管理
└── tsconfig.json         # TypeScript配置
```

#### 二次开发就绪验证步骤

```bash
# 1. 后端编译验证
cd RuoYi-Vue-Plus
mvn compile
# 预期: BUILD SUCCESS

# 2. 前端构建验证
cd plus-ui
npm run build:prod
# 预期: dist目录生成，构建成功

# 3. 代码生成器验证
# 登录系统 → 系统工具 → 代码生成
# 导入数据库表 → 生成代码 → 预览/下载

# 4. 业务功能验证
# 登录后执行以下操作：
# - 系统管理→用户管理：查看/新增/编辑用户
# - 系统管理→角色管理：查看/新增/编辑角色
# - 系统管理→菜单管理：查看菜单树
# - 系统监控→在线用户：查看在线用户列表
```

### 1.3.8 异常处理与回退方案

#### 异常场景与处理策略

| 异常场景 | 触发条件 | 诊断方式 | 处理策略 | 回退方案 |
|---------|---------|---------|---------|---------|
| JDK版本不满足 | java -version < 17 | 检查版本输出 | 安装JDK 17/21，配置JAVA_HOME | 卸载旧版本JDK后重新安装 |
| Maven依赖下载失败 | 网络不可达 | 查看mvn输出错误日志 | 配置华为云Maven镜像源 | 删除~/.m2/repository后重试 |
| MySQL服务未运行 | 连接拒绝 | `mysql -u root -p` 测试连接 | 启动MySQL服务 | 重装MySQL |
| MySQL密码不匹配 | 认证失败 | 后端日志Access denied | 修改application-dev.yml密码 | 重置MySQL root密码 |
| Redis服务未运行 | 连接拒绝 | `redis-cli ping` 无响应 | 启动Redis服务 | 重装Redis |
| Redis密码不匹配 | NOAUTH错误 | 后端日志Redis连接失败 | 统一redis.conf与yml密码 | 重启Redis并修改配置 |
| 数据库ry-vue已存在 | SQL执行冲突 | `SHOW DATABASES LIKE 'ry-vue'` | 备份后DROP重建 | 从备份恢复 |
| SQL脚本执行失败 | 语法/字符集不兼容 | MySQL错误日志 | 确认utf8mb4字符集和MySQL 8.0+ | 删除数据库重新初始化 |
| 后端启动-端口占用 | 8080已被占用 | `netstat -ano \| findstr 8080` | 终止占用进程或修改server.port | 修改配置使用其他端口 |
| 后端启动-依赖缺失 | ClassNotFoundException | 后端启动日志 | 重新执行`mvn clean install` | 删除本地Maven仓库缓存后重试 |
| 前端依赖安装失败 | 网络超时 | npm ERR!日志 | 切换npm镜像源 | `npm cache clean --force`后重试 |
| 前端启动-端口占用 | 80端口已被占用 | Vite报错EADDRINUSE | 修改.env.development中端口 | 终止占用80端口的进程 |
| 前端API代理失败 | 后端未启动 | Network面板502/超时 | 先启动后端再启动前端 | 检查vite.config.ts代理配置 |
| 登录失败-验证码错误 | 验证码输入不匹配 | 后端返回验证码错误 | 重新获取验证码 | 刷新页面 |
| 登录失败-后端未启动 | 网络错误 | 前端控制台Network Error | 启动后端服务 | 检查后端健康状态 |

#### 回退优先级

```plantuml
@startuml
start
:发现异常;
if (可修复配置?) then (是)
  :修改配置文件;
  :重启相关服务;
else (否)
  if (可重新安装依赖?) then (是)
    :清除缓存/依赖;
    :重新安装;
  else (否)
    if (需重建数据库?) then (是)
      :备份现有数据;
      :DROP DATABASE;
      :重新执行SQL脚本;
    else (否)
      :重新克隆项目;
      :从头执行搭建流程;
    endif
  endif
endif
stop
@enduml
```

# **2. 接口设计**

## **2.1 总体设计**

### 前后端交互架构

```plantuml
@startuml
!theme plain

actor "浏览器" as browser
component "Vite Dev Server\n:80" as vite
component "Spring Boot\n:8080" as backend

browser --> vite : 1. 页面请求\nhttp://localhost:80
browser --> vite : 2. API请求\n/dev-api/*
vite --> backend : 3. 代理转发\nhttp://localhost:8080/*\n(去除/dev-api前缀)
backend --> vite : 4. 返回JSON响应
vite --> browser : 5. 返回响应数据

note right of vite
  代理规则:
  /dev-api/auth/login → /auth/login
  /dev-api/system/user/list → /system/user/list
end note

@enduml
```

### 请求/响应规范

- **请求格式**：JSON（Content-Type: application/json）
- **响应格式**：统一包装 `{ code, msg, data }`
- **认证方式**：Sa-Token，Header携带 `Authorization: token值`
- **接口加密**：RSA+AES动态加密（VITE_APP_ENCRYPT=true时启用）
- **多租户**：Header携带 `tenant-id: 租户ID`（默认000000）

## **2.2 接口清单**

### 核心接口列表

| 接口路径 | 方法 | 说明 | 认证 | 请求参数 | 响应数据 |
|---------|------|------|------|---------|---------|
| /auth/login | POST | 用户登录 | 否 | { username, password, code, uuid } | { token, userInfo } |
| /auth/logout | POST | 用户登出 | 是 | - | void |
| /auth/register | POST | 用户注册 | 否 | { username, password } | void |
| /system/user/list | GET | 用户列表 | 是 | { pageNum, pageSize, ... } | { rows, total } |
| /system/role/list | GET | 角色列表 | 是 | { pageNum, pageSize, ... } | { rows, total } |
| /system/menu/list | GET | 菜单列表 | 是 | - | menuTree |
| /system/dept/list | GET | 部门列表 | 是 | - | deptTree |
| /system/dict/type/list | GET | 字典类型列表 | 是 | { pageNum, pageSize } | { rows, total } |
| /system/post/list | GET | 岗位列表 | 是 | { pageNum, pageSize } | { rows, total } |
| /monitor/online/list | GET | 在线用户列表 | 是 | { pageNum, pageSize } | { rows, total } |
| /tool/gen/list | GET | 代码生成表列表 | 是 | { pageNum, pageSize } | { rows, total } |
| /tool/gen/import | POST | 导入表结构 | 是 | { tables } | void |
| /actuator/health | GET | 健康检查 | 否 | - | { status } |
| /captchaImage | GET | 获取验证码 | 否 | - | { img, uuid, enabled } |
| /getInfo | GET | 获取当前用户信息 | 是 | - | { user, roles, permissions } |
| /getRouters | GET | 获取动态路由 | 是 | - | routeTree |

### 登录认证时序

```plantuml
@startuml
actor "浏览器" as browser
participant "Vite Proxy" as proxy
participant "Spring Boot" as backend
participant "Sa-Token" as satoken
database "MySQL" as mysql
database "Redis" as redis

browser -> proxy : POST /dev-api/auth/login\n{username, password, code, uuid}
proxy -> backend : POST /auth/login

backend -> redis : 获取验证码(uuid)
redis --> backend : 返回验证码值
backend -> backend : 校验验证码

backend -> mysql : SELECT * FROM sys_user\nWHERE user_name = ?
mysql --> backend : 返回用户记录
backend -> backend : BCrypt校验密码

backend -> satoken : StpUtil.login(userId)
satoken -> redis : 存储Token会话
satoken --> backend : 返回Token值

backend --> proxy : {code:200, data:{token}}
proxy --> browser : 响应Token

browser -> browser : 存储Token到Cookie

browser -> proxy : GET /dev-api/getRouters\nHeader: Authorization: token
proxy -> backend : GET /getRouters
backend -> satoken : 校验Token有效性
satoken -> redis : 查询Token会话
satoken --> backend : Token有效
backend -> mysql : 查询用户菜单权限
mysql --> backend : 返回菜单数据
backend --> proxy : {code:200, data:routeTree}
proxy --> browser : 返回路由数据

@enduml
```

# **4. 数据模型**

## **4.1 设计目标**

1. 支持RuoYi-Vue-Plus系统全部核心业务表
2. 支持多租户数据隔离（tenant_id字段）
3. 支持逻辑删除（del_flag字段）
4. 支持审计字段（create_by, create_time, update_by, update_time）
5. 字符集统一为utf8mb4，支持中文和Emoji

## **4.2 模型实现**

### 核心数据表ER关系

```plantuml
@startuml
!theme plain

entity "sys_user\n系统用户表" as user {
  * user_id : BIGINT <<PK>>
  --
  tenant_id : VARCHAR(20) <<租户ID>>
  dept_id : BIGINT <<部门ID>>
  user_name : VARCHAR(30) <<用户名>>
  nick_name : VARCHAR(30) <<昵称>>
  password : VARCHAR(100) <<密码(BCrypt)>>
  status : CHAR(1) <<状态(0正常1停用)>>
  del_flag : CHAR(1) <<删除标志>>
  create_by : BIGINT <<创建者>>
  create_time : DATETIME <<创建时间>>
}

entity "sys_role\n角色表" as role {
  * role_id : BIGINT <<PK>>
  --
  tenant_id : VARCHAR(20)
  role_name : VARCHAR(30)
  role_key : VARCHAR(100)
  role_sort : INT
  data_scope : CHAR(1)
  status : CHAR(1)
  del_flag : CHAR(1)
}

entity "sys_menu\n菜单表" as menu {
  * menu_id : BIGINT <<PK>>
  --
  menu_name : VARCHAR(50)
  parent_id : BIGINT
  order_num : INT
  path : VARCHAR(200)
  component : VARCHAR(255)
  menu_type : CHAR(1)
  perms : VARCHAR(100)
  status : CHAR(1)
}

entity "sys_dept\n部门表" as dept {
  * dept_id : BIGINT <<PK>>
  --
  tenant_id : VARCHAR(20)
  parent_id : BIGINT
  dept_name : VARCHAR(30)
  order_num : INT
  status : CHAR(1)
  del_flag : CHAR(1)
}

entity "sys_user_role\n用户角色关联" as user_role {
  * user_id : BIGINT <<FK>>
  * role_id : BIGINT <<FK>>
}

entity "sys_role_menu\n角色菜单关联" as role_menu {
  * role_id : BIGINT <<FK>>
  * menu_id : BIGINT <<FK>>
}

entity "sys_dict_type\n字典类型表" as dict_type {
  * dict_id : BIGINT <<PK>>
  --
  tenant_id : VARCHAR(20)
  dict_name : VARCHAR(100)
  dict_type : VARCHAR(100)
  status : CHAR(1)
}

entity "sys_dict_data\n字典数据表" as dict_data {
  * dict_code : BIGINT <<PK>>
  --
  dict_type : VARCHAR(100)
  dict_label : VARCHAR(100)
  dict_value : VARCHAR(100)
  dict_sort : INT
  status : CHAR(1)
}

entity "sys_post\n岗位表" as post {
  * post_id : BIGINT <<PK>>
  --
  tenant_id : VARCHAR(20)
  post_code : VARCHAR(64)
  post_name : VARCHAR(50)
  post_sort : INT
  status : CHAR(1)
}

user ||--o{ user_role
role ||--o{ user_role
role ||--o{ role_menu
menu ||--o{ role_menu
dept ||--o{ user
dict_type ||--o{ dict_data

@enduml
```

### 数据库初始化数据模型

```plantuml
@startuml
!theme plain

database "ry-vue" as db {
  folder "核心系统表 (ry_vue_5.X.sql)" as core {
    card "sys_user" as t1
    card "sys_role" as t2
    card "sys_menu" as t3
    card "sys_dept" as t4
    card "sys_dict_type" as t5
    card "sys_dict_data" as t6
    card "sys_post" as t7
    card "sys_config" as t8
    card "sys_oper_log" as t9
    card "sys_logininfor" as t10
    card "sys_job_log" as t11
    card "sys_notice" as t12
    card "sys_oss" as t13
    card "sys_tenant" as t14
  }

  folder "任务调度表 (ry_job.sql)" as job {
    card "sj_group_config" as j1
    card "sj_job" as j2
    card "sj_job_log" as j3
  }

  folder "工作流表 (ry_workflow.sql)" as wf {
    card "flow_definition" as w1
    card "flow_instance" as w2
    card "flow_task" as w3
    card "flow_his_task" as w4
  }
}

@enduml
```

### 关键配置数据模型

**后端配置模型 (application-dev.yml)**

```yaml
# 服务器配置
server:
  port: 8080                    # 服务端口

# 数据源配置
spring:
  datasource:
    dynamic:
      datasource:
        master:
          url: jdbc:mysql://localhost:3306/ry-vue?...  # 数据库URL
          username: root                                    # 数据库用户名
          password: root                                    # 数据库密码

# Redis配置
spring:
  data:
    redis:
      host: localhost            # Redis地址
      port: 6379                 # Redis端口
      password: ruoyi123         # Redis密码
      database: 0                # Redis数据库索引

# Sa-Token配置
sa-token:
  token-name: Authorization      # Token名称
  timeout: 86400                 # Token有效期(秒)

# 多租户配置
tenant:
  enable: true                   # 多租户开关
```

**前端配置模型 (.env.development)**

```bash
VITE_APP_BASE_API = '/dev-api'                              # API基础路径
VITE_APP_PORT = 80                                          # 前端服务端口
VITE_APP_ENCRYPT = true                                     # 接口加密开关
VITE_APP_CLIENT_ID = e5cd7e4891bf95d1d19206ce24a7b32e       # 客户端ID
VITE_APP_WEBSOCKET = false                                  # WebSocket开关
VITE_APP_SSE = true                                         # SSE推送开关
```