import { spawn } from 'node:child_process';
import process from 'node:process';
import puppeteer from 'puppeteer';

const chromePath = puppeteer.executablePath();
const args = ['test', '--watch=false', '--browsers=ChromeHeadless', ...process.argv.slice(2)];

const child = spawn('npx', ['ng', ...args], {
  stdio: 'inherit',
  env: {
    ...process.env,
    CHROME_BIN: chromePath
  },
  shell: process.platform === 'win32'
});

child.on('exit', (code) => {
  process.exit(code ?? 1);
});
