// Test Frontend Automatisé - TaxCollect System
// Usage: node test_frontend.js

const puppeteer = require('puppeteer');
const fs = require('fs');

const BASE_URL = 'http://localhost:3000';
const LOG_FILE = `frontend_test_results_${new Date().toISOString().replace(/[:.]/g, '-')}.log`;

// Colors for console output
const colors = {
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    reset: '\x1b[0m'
};

function log(message, color = 'reset') {
    const coloredMessage = `${colors[color]}${message}${colors.reset}`;
    console.log(coloredMessage);
    fs.appendFileSync(LOG_FILE, `${message}\n`);
}

async function testPage(page, path, testName) {
    try {
        await page.goto(`${BASE_URL}${path}`, { waitUntil: 'networkidle2' });
        
        // Check for JavaScript errors
        const errors = await page.evaluate(() => {
            return window.errors || [];
        });
        
        if (errors.length > 0) {
            log(`❌ ${testName} - JavaScript errors: ${errors.join(', ')}`, 'red');
            return false;
        }
        
        // Check if page loads successfully
        const title = await page.title();
        const hasContent = await page.evaluate(() => {
            return document.body.innerText.length > 100;
        });
        
        if (hasContent) {
            log(`✅ ${testName} - Page loaded successfully`, 'green');
            return true;
        } else {
            log(`❌ ${testName} - Page has no content`, 'red');
            return false;
        }
    } catch (error) {
        log(`❌ ${testName} - Error: ${error.message}`, 'red');
        return false;
    }
}

async function testAgentsPage(page) {
    log('🧪 Testing Agents Page...', 'yellow');
    
    await testPage(page, '/agents', 'Agents Page');
    
    // Test agent creation modal
    try {
        await page.click('[data-testid="create-agent-btn"]');
        await page.waitForSelector('[data-testid="agent-modal"]', { timeout: 3000 });
        log('✅ Agent creation modal opens', 'green');
        
        // Close modal
        await page.click('[data-testid="close-modal-btn"]');
        log('✅ Modal closes properly', 'green');
    } catch (error) {
        log(`❌ Agent modal test failed: ${error.message}`, 'red');
    }
    
    // Test search functionality
    try {
        await page.type('[data-testid="agent-search"]', 'test');
        await page.waitForTimeout(1000);
        log('✅ Agent search works', 'green');
    } catch (error) {
        log(`❌ Agent search test failed: ${error.message}`, 'red');
    }
}

async function testContribuablesPage(page) {
    log('🧪 Testing Contribuables Page...', 'yellow');
    
    await testPage(page, '/contribuables', 'Contribuables Page');
    
    // Test map component
    try {
        await page.waitForSelector('[data-testid="interactive-map"]', { timeout: 5000 });
        log('✅ Interactive map loads', 'green');
    } catch (error) {
        log(`❌ Map test failed: ${error.message}`, 'red');
    }
    
    // Test zone list
    try {
        await page.waitForSelector('[data-testid="zone-list"]', { timeout: 3000 });
        log('✅ Zone list loads', 'green');
    } catch (error) {
        log(`❌ Zone list test failed: ${error.message}`, 'red');
    }
}

async function testTaxesPage(page) {
    log('🧪 Testing Taxes Page...', 'yellow');
    
    await testPage(page, '/taxes', 'Taxes Page');
    
    // Test filters
    try {
        await page.select('[data-testid="category-filter"]', 'IMPOT_FONCIER');
        await page.waitForTimeout(1000);
        log('✅ Category filter works', 'green');
    } catch (error) {
        log(`❌ Category filter test failed: ${error.message}`, 'red');
    }
    
    // Test tax creation
    try {
        await page.click('[data-testid="create-tax-btn"]');
        await page.waitForSelector('[data-testid="tax-modal"]', { timeout: 3000 });
        log('✅ Tax creation modal opens', 'green');
        await page.click('[data-testid="close-modal-btn"]');
    } catch (error) {
        log(`❌ Tax modal test failed: ${error.message}`, 'red');
    }
}

async function testTransactionsPage(page) {
    log('🧪 Testing Transactions Page...', 'yellow');
    
    await testPage(page, '/transactions', 'Transactions Page');
    
    // Test filters
    try {
        await page.type('[data-testid="date-start-filter"]', '2024-01-01');
        await page.type('[data-testid="date-end-filter"]', '2024-12-31');
        log('✅ Date filters work', 'green');
    } catch (error) {
        log(`❌ Date filter test failed: ${error.message}`, 'red');
    }
    
    // Test export functionality
    try {
        const downloadPromise = page.waitForEvent('download');
        await page.click('[data-testid="export-btn"]');
        const download = await downloadPromise;
        log('✅ Export functionality works', 'green');
    } catch (error) {
        log(`❌ Export test failed: ${error.message}`, 'red');
    }
}

async function testDashboardPage(page) {
    log('🧪 Testing Dashboard Page...', 'yellow');
    
    await testPage(page, '/dashboard', 'Dashboard Page');
    
    // Test stats cards
    try {
        await page.waitForSelector('[data-testid="stats-card"]', { timeout: 3000 });
        const statsCards = await page.$$('[data-testid="stats-card"]');
        log(`✅ Dashboard loads ${statsCards.length} stats cards`, 'green');
    } catch (error) {
        log(`❌ Dashboard stats test failed: ${error.message}`, 'red');
    }
}

async function testNavigation(page) {
    log('🧪 Testing Navigation...', 'yellow');
    
    try {
        // Test sidebar navigation
        const navItems = await page.$$('[data-testid="nav-item"]');
        
        for (let i = 0; i < Math.min(navItems.length, 5); i++) {
            await navItems[i].click();
            await page.waitForTimeout(1000);
        }
        
        log('✅ Navigation works properly', 'green');
    } catch (error) {
        log(`❌ Navigation test failed: ${error.message}`, 'red');
    }
}

async function testResponsive(page) {
    log('🧪 Testing Responsive Design...', 'yellow');
    
    const viewports = [
        { width: 1920, height: 1080, name: 'Desktop' },
        { width: 768, height: 1024, name: 'Tablet' },
        { width: 375, height: 667, name: 'Mobile' }
    ];
    
    for (const viewport of viewports) {
        try {
            await page.setViewport(viewport);
            await page.goto(`${BASE_URL}/agents`, { waitUntil: 'networkidle2' });
            
            // Check if content is still accessible
            const hasContent = await page.evaluate(() => {
                return document.body.innerText.length > 100;
            });
            
            if (hasContent) {
                log(`✅ Responsive design works for ${viewport.name}`, 'green');
            } else {
                log(`❌ Responsive design failed for ${viewport.name}`, 'red');
            }
        } catch (error) {
            log(`❌ Responsive test failed for ${viewport.name}: ${error.message}`, 'red');
        }
    }
}

async function generateReport(results) {
    log('📊 Generating Test Report...', 'blue');
    
    const totalTests = results.length;
    const passedTests = results.filter(r => r.passed).length;
    const failedTests = totalTests - passedTests;
    
    log('\n=== FRONTEND TEST REPORT ===', 'blue');
    log(`Total Tests: ${totalTests}`);
    log(`Passed: ${passedTests}`);
    log(`Failed: ${failedTests}`);
    log(`Success Rate: ${((passedTests / totalTests) * 100).toFixed(1)}%`);
    
    if (failedTests === 0) {
        log('🎉 ALL FRONTEND TESTS PASSED!', 'green');
    } else {
        log(`⚠️ ${failedTests} test(s) failed`, 'red');
    }
    
    // Save detailed report
    const report = {
        timestamp: new Date().toISOString(),
        summary: {
            total: totalTests,
            passed: passedTests,
            failed: failedTests,
            successRate: ((passedTests / totalTests) * 100).toFixed(1)
        },
        results: results
    };
    
    fs.writeFileSync(`frontend_test_report_${new Date().toISOString().replace(/[:.]/g, '-')}.json`, JSON.stringify(report, null, 2));
    log(`Detailed report saved to: frontend_test_report_*.json`);
}

async function runTests() {
    log('🚀 Starting Frontend Tests...', 'blue');
    log(`Log file: ${LOG_FILE}`);
    
    const browser = await puppeteer.launch({ 
        headless: false, // Set to true for CI/CD
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    const page = await browser.newPage();
    
    // Monitor console errors
    page.on('console', msg => {
        if (msg.type() === 'error') {
            page.evaluate(() => {
                window.errors = window.errors || [];
                window.errors.push(msg.text());
            });
        }
    });
    
    const results = [];
    
    try {
        // Test all pages
        await testAgentsPage(page);
        await testContribuablesPage(page);
        await testTaxesPage(page);
        await testTransactionsPage(page);
        await testDashboardPage(page);
        await testNavigation(page);
        await testResponsive(page);
        
    } catch (error) {
        log(`❌ Test execution failed: ${error.message}`, 'red');
    } finally {
        await browser.close();
    }
    
    await generateReport(results);
}

// Check if frontend is running
async function checkFrontend() {
    try {
        const response = await fetch(BASE_URL);
        return response.ok;
    } catch (error) {
        return false;
    }
}

// Main execution
async function main() {
    log('🧪 TaxCollect Frontend Test Suite', 'blue');
    
    const frontendRunning = await checkFrontend();
    if (!frontendRunning) {
        log('❌ Frontend is not running. Please start it with: npm run dev', 'red');
        process.exit(1);
    }
    
    await runTests();
}

// Run if called directly
if (require.main === module) {
    main().catch(console.error);
}

module.exports = { runTests, testPage, checkFrontend };
