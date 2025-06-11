const fs = require('fs');
const path = require('path');
const { validateMarkdown } = require('../src/validateMarkdown');

function loadFixture(name) {
  return fs.readFileSync(path.resolve(__dirname, '__fixtures__/markdown', name), 'utf-8');
}

describe('validateMarkdown', () => {
  beforeEach(() => {
    jest.restoreAllMocks();
  });

  it('returns true for well-formed markdown', () => {
    const md = loadFixture('good.md');
    expect(validateMarkdown(md)).toBe(true);
  });

  it('returns true for markdown with only links and images', () => {
    const md = loadFixture('links_and_images.md');
    expect(validateMarkdown(md)).toBe(true);
  });

  it('handles empty string input by returning false', () => {
    expect(validateMarkdown('')).toBe(false);
  });

  it('throws TypeError when input is null', () => {
    expect(() => validateMarkdown(null)).toThrow(TypeError);
  });

  it('throws TypeError when input is undefined', () => {
    expect(() => validateMarkdown(undefined)).toThrow(TypeError);
  });

  it('throws an error when markdown is malformed', () => {
    const md = loadFixture('bad.md');
    expect(() => validateMarkdown(md)).toThrow(/Malformed markdown/);
  });
});