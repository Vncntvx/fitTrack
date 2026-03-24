/**
 * FitTrack Web Admin
 * 管理控制台 JavaScript
 */

const API_BASE = '';
const TOKEN_KEY = 'fittrack_token';
let authToken = null;

// 初始化
document.addEventListener('DOMContentLoaded', function() {
    initAuthToken();
    initNavigation();
    initBackupForm();
    loadDashboard();
    loadWorkouts();
    loadSettings();
    loadBackupList();
    loadBackupRecords();
    loadSystemInfo();
});

// 导航切换
function initNavigation() {
    const navBtns = document.querySelectorAll('.nav-btn');
    navBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            const sectionId = this.getAttribute('data-section');
            switchSection(sectionId);
            
            navBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
        });
    });
}

function switchSection(sectionId) {
    document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
    document.getElementById(sectionId).classList.add('active');
}

// 显示消息
function showMessage(message, type = 'info') {
    const container = document.getElementById('message-container');
    const div = document.createElement('div');
    div.className = type === 'error' ? 'error' : 'success';
    div.textContent = message;
    container.appendChild(div);
    setTimeout(() => div.remove(), 5000);
}

// API 请求封装
async function apiRequest(method, endpoint, data = null) {
    try {
        const options = {
            method: method,
            headers: {
                'Content-Type': 'application/json'
            }
        };
        if (authToken) {
            options.headers['Authorization'] = `Bearer ${authToken}`;
            options.headers['X-FitTrack-Token'] = authToken;
        }
        
        if (data) {
            options.body = JSON.stringify(data);
        }
        
        const response = await fetch(`${API_BASE}${endpoint}`, options);
        
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        
        return await response.json();
    } catch (error) {
        console.error('API Error:', error);
        throw error;
    }
}

function initAuthToken() {
    const params = new URLSearchParams(window.location.search);
    const tokenFromQuery = params.get('token');
    if (tokenFromQuery && tokenFromQuery.trim()) {
        authToken = tokenFromQuery.trim();
        localStorage.setItem(TOKEN_KEY, authToken);
        const cleanUrl = `${window.location.origin}${window.location.pathname}`;
        window.history.replaceState({}, document.title, cleanUrl);
        return;
    }
    const saved = localStorage.getItem(TOKEN_KEY);
    if (saved && saved.trim()) {
        authToken = saved.trim();
    }
}

// 加载概览数据
async function loadDashboard() {
    try {
        const stats = await apiRequest('GET', '/api/stats');
        const totalWorkouts = stats.totalWorkouts ?? stats.totalCount ?? 0;
        const weeklyCount = stats.weeklyCount ?? stats.workoutDaysThisWeek ?? 0;
        const totalMinutes = stats.totalMinutes ?? stats.totalMinutesThisWeek ?? 0;
        const avgIntensity = stats.avgIntensity ?? stats.mostFrequentType ?? '-';
        document.getElementById('total-workouts').textContent = totalWorkouts;
        document.getElementById('weekly-count').textContent = weeklyCount;
        document.getElementById('total-minutes').textContent = totalMinutes;
        document.getElementById('avg-intensity').textContent = getIntensityLabel(avgIntensity);
        
        // 加载最近运动
        const workouts = await apiRequest('GET', '/api/workouts');
        const recent = workouts.slice(0, 5);
        const container = document.getElementById('recent-workouts');
        
        if (recent.length === 0) {
            container.innerHTML = '<div class="empty-state">暂无运动记录</div>';
        } else {
            container.innerHTML = `
                <table>
                    <thead>
                        <tr>
                            <th>日期</th>
                            <th>类型</th>
                            <th>时长</th>
                            <th>强度</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${recent.map(w => `
                            <tr>
                                <td>${formatDate(w.datetime)}</td>
                                <td>${getTypeLabel(w.type)}</td>
                                <td>${w.durationMinutes} 分钟</td>
                                <td><span class="badge badge-${getIntensityClass(w.intensity)}">${getIntensityLabel(w.intensity)}</span></td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
        }
    } catch (error) {
        document.getElementById('recent-workouts').innerHTML = '<div class="error">加载失败: ' + error.message + '</div>';
    }
}

// 加载运动记录
async function loadWorkouts() {
    try {
        const workouts = await apiRequest('GET', '/api/workouts');
        const container = document.getElementById('workouts-table');
        
        if (workouts.length === 0) {
            container.innerHTML = '<div class="empty-state">暂无运动记录</div>';
        } else {
            container.innerHTML = `
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>日期</th>
                            <th>类型</th>
                            <th>时长</th>
                            <th>强度</th>
                            <th>备注</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${workouts.map(w => `
                            <tr>
                                <td>${w.id}</td>
                                <td>${formatDate(w.datetime)}</td>
                                <td>${getTypeLabel(w.type)}</td>
                                <td>${w.durationMinutes} 分钟</td>
                                <td><span class="badge badge-${getIntensityClass(w.intensity)}">${getIntensityLabel(w.intensity)}</span></td>
                                <td>${w.note || '-'}</td>
                                <td>
                                    <button class="btn btn-danger" onclick="deleteWorkout(${w.id})">删除</button>
                                </td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
        }
    } catch (error) {
        document.getElementById('workouts-table').innerHTML = '<div class="error">加载失败: ' + error.message + '</div>';
    }
}

// 加载设置
async function loadSettings() {
    try {
        const settings = await apiRequest('GET', '/api/settings');
        document.getElementById('days-goal').value = settings.weeklyWorkoutDaysGoal || 3;
        document.getElementById('minutes-goal').value = settings.weeklyWorkoutMinutesGoal || 150;
    } catch (error) {
        console.error('加载设置失败:', error);
    }
}

// 保存设置
document.getElementById('settings-form').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    try {
        await apiRequest('PUT', '/api/settings', {
            weeklyWorkoutDaysGoal: parseInt(document.getElementById('days-goal').value),
            weeklyWorkoutMinutesGoal: parseInt(document.getElementById('minutes-goal').value)
        });
        showMessage('设置已保存');
    } catch (error) {
        showMessage('保存失败: ' + error.message, 'error');
    }
});

// 添加运动记录弹窗
function showAddWorkoutModal() {
    document.getElementById('add-workout-modal').classList.add('active');
}

function closeModal() {
    document.getElementById('add-workout-modal').classList.remove('active');
}

// 提交运动记录
document.getElementById('add-workout-form').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    try {
        await apiRequest('POST', '/api/workouts', {
            type: document.getElementById('workout-type').value,
            durationMinutes: parseInt(document.getElementById('workout-duration').value),
            intensity: document.getElementById('workout-intensity').value,
            note: document.getElementById('workout-note').value,
            datetime: new Date().toISOString()
        });
        
        closeModal();
        showMessage('记录已添加');
        loadWorkouts();
        loadDashboard();
    } catch (error) {
        showMessage('添加失败: ' + error.message, 'error');
    }
});

// 删除运动记录
async function deleteWorkout(id) {
    if (!confirm('确定要删除这条记录吗？')) return;
    
    try {
        await apiRequest('DELETE', `/api/workouts/${id}`);
        showMessage('记录已删除');
        loadWorkouts();
        loadDashboard();
    } catch (error) {
        showMessage('删除失败: ' + error.message, 'error');
    }
}

// 加载备份列表
async function loadBackupList() {
    try {
        const configs = await apiRequest('GET', '/api/backup-configs');
        const container = document.getElementById('backup-list');
        
        if (configs.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <p>暂无备份配置</p>
                    <p style="font-size: 14px; margin-top: 10px;">请先创建备份配置</p>
                </div>
            `;
        } else {
            container.innerHTML = `
                <table>
                    <thead>
                        <tr>
                            <th>名称</th>
                            <th>类型</th>
                            <th>路径/桶</th>
                            <th>操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${configs.map(c => `
                            <tr>
                                <td>${c.displayName}</td>
                                <td>${c.providerType}</td>
                                <td>${c.bucketOrPath}</td>
                                <td>
                                    <button class="btn btn-primary" onclick="backupNow(${c.id})">备份</button>
                                    <button class="btn btn-danger" onclick="deleteBackupConfig(${c.id})">删除</button>
                                </td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
        }
        loadBackupRecords();
    } catch (error) {
        document.getElementById('backup-list').innerHTML = '<div class="error">加载失败: ' + error.message + '</div>';
    }
}

// 立即备份
async function createBackup() {
    try {
        const configs = await apiRequest('GET', '/api/backup-configs');
        if (configs.length === 0) {
            showMessage('请先创建备份配置', 'error');
            return;
        }
        
        const defaultConfig = configs.find(c => c.isDefault) || configs[0];
        await apiRequest('POST', `/api/backup/${defaultConfig.id}`);
        showMessage('备份已开始');
        loadBackupRecords();
    } catch (error) {
        showMessage('备份失败: ' + error.message, 'error');
    }
}

async function backupNow(id) {
    try {
        await apiRequest('POST', `/api/backup/${id}`);
        showMessage('备份成功');
        loadBackupRecords();
    } catch (error) {
        showMessage('备份失败: ' + error.message, 'error');
    }
}

// 删除备份配置
async function deleteBackupConfig(id) {
    if (!confirm('确定要删除这个备份配置吗？')) return;
    
    try {
        await apiRequest('DELETE', `/api/backup-configs/${id}`);
        showMessage('配置已删除');
        loadBackupList();
        loadBackupRecords();
    } catch (error) {
        showMessage('删除失败: ' + error.message, 'error');
    }
}

function initBackupForm() {
    const providerTypeSelect = document.getElementById('backup-provider-type');
    const form = document.getElementById('backup-config-form');
    if (!providerTypeSelect || !form) return;

    const applyProviderFields = () => {
        const providerType = providerTypeSelect.value;
        const isWebDav = providerType === 'webdav';

        document.getElementById('backup-webdav-credentials').style.display = isWebDav ? '' : 'none';
        document.getElementById('backup-s3-credentials').style.display = isWebDav ? 'none' : '';
        document.getElementById('backup-region-group').style.display = isWebDav ? 'none' : '';
        document.getElementById('backup-path-label').textContent = isWebDav ? '备份路径' : 'S3 存储桶';
        document.getElementById('backup-path-bucket').placeholder = isWebDav ? '/backups' : 'my-bucket';
    };

    providerTypeSelect.addEventListener('change', applyProviderFields);
    applyProviderFields();

    form.addEventListener('submit', async function(e) {
        e.preventDefault();

        const providerType = providerTypeSelect.value;
        const isWebDav = providerType === 'webdav';
        const displayName = document.getElementById('backup-display-name').value.trim();
        const endpoint = document.getElementById('backup-endpoint').value.trim();
        const pathOrBucket = document.getElementById('backup-path-bucket').value.trim();
        const isDefault = document.getElementById('backup-is-default').checked;

        if (!displayName || !endpoint || !pathOrBucket) {
            showMessage('请填写完整配置', 'error');
            return;
        }

        const payload = {
            providerType,
            displayName,
            endpoint,
            isDefault
        };

        if (isWebDav) {
            const username = document.getElementById('backup-webdav-username').value.trim();
            const password = document.getElementById('backup-webdav-password').value;
            if (!username || !password) {
                showMessage('请填写 WebDAV 用户名和密码', 'error');
                return;
            }
            payload.path = pathOrBucket;
            payload.username = username;
            payload.password = password;
        } else {
            const accessKey = document.getElementById('backup-s3-access-key').value.trim();
            const secretKey = document.getElementById('backup-s3-secret-key').value;
            const region = document.getElementById('backup-region').value.trim();
            if (!accessKey || !secretKey) {
                showMessage('请填写 S3 Access Key 和 Secret Key', 'error');
                return;
            }
            payload.bucket = pathOrBucket;
            payload.region = region || 'us-east-1';
            payload.accessKey = accessKey;
            payload.secretKey = secretKey;
        }

        try {
            await apiRequest('POST', '/api/backup-configs', payload);
            form.reset();
            providerTypeSelect.value = 'webdav';
            applyProviderFields();
            showMessage('备份配置创建成功');
            loadBackupList();
        } catch (error) {
            showMessage('创建配置失败: ' + error.message, 'error');
        }
    });
}

async function loadBackupRecords() {
    const container = document.getElementById('backup-records');
    if (!container) return;
    try {
        const records = await apiRequest('GET', '/api/backup-records');
        if (!records || records.length === 0) {
            container.innerHTML = '<div class="empty-state">暂无备份记录</div>';
            return;
        }
        container.innerHTML = `
            <table>
                <thead>
                    <tr>
                        <th>时间</th>
                        <th>提供者</th>
                        <th>状态</th>
                        <th>目标路径</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    ${records.slice(0, 20).map(r => `
                        <tr>
                            <td>${formatDate(r.createdAt)}</td>
                            <td>${(r.providerType || '-').toUpperCase()}</td>
                            <td>${r.status || '-'}</td>
                            <td>${r.targetPath || '-'}</td>
                            <td>
                                <button class="btn btn-primary" onclick="restoreRecord(${r.id})">恢复</button>
                            </td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
        `;
    } catch (error) {
        container.innerHTML = '<div class="error">加载备份记录失败: ' + error.message + '</div>';
    }
}

async function restoreRecord(recordId) {
    if (!confirm('恢复会覆盖当前本地数据，是否继续？')) return;
    try {
        await apiRequest('POST', '/api/restore', { recordId });
        showMessage('恢复成功');
    } catch (error) {
        showMessage('恢复失败: ' + error.message, 'error');
    }
}

// 加载系统信息
async function loadSystemInfo() {
    try {
        const health = await apiRequest('GET', '/health');
        const container = document.getElementById('system-info');
        
        container.innerHTML = `
            <div style="display: grid; gap: 15px;">
                <div class="form-group">
                    <label>应用状态</label>
                    <input type="text" value="${health.status === 'ok' ? '正常运行' : '异常'}" readonly>
                </div>
                <div class="form-group">
                    <label>服务器时间</label>
                    <input type="text" value="${formatDate(health.timestamp)}" readonly>
                </div>
                <div class="form-group">
                    <label>API 端点</label>
                    <input type="text" value="/api/workouts, /api/settings, /api/backup-configs" readonly>
                </div>
            </div>
        `;
    } catch (error) {
        document.getElementById('system-info').innerHTML = '<div class="error">加载失败: ' + error.message + '</div>';
    }
}

// 工具函数
function formatDate(dateStr) {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return date.toLocaleString('zh-CN');
}

function getTypeLabel(type) {
    const labels = {
        'strength': '力量训练',
        'running': '跑步',
        'swimming': '游泳',
        'cycling': '骑行',
        'yoga': '瑜伽',
        'other': '其他'
    };
    return labels[type] || type;
}

function getIntensityLabel(intensity) {
    const labels = {
        'light': '轻度',
        'moderate': '中度',
        'high': '高强度',
        'low': '低',
        'medium': '中度'
    };
    return labels[intensity] || intensity;
}

function getIntensityClass(intensity) {
    const classes = {
        'light': 'info',
        'moderate': 'warning',
        'high': 'success',
        'low': 'info',
        'medium': 'warning'
    };
    return classes[intensity] || 'info';
}
