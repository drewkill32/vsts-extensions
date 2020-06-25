import path = require("path");
import fs = require("fs");
import MarkdownIt = require("markdown-it");
import mdtl = require("markdown-it-task-lists");

function run() {
  try {
    const [fileName, output, toBase64String] = process.argv.slice(2);
    const toBase64 = toBase64String.toLowerCase() === "true";
    if (!fs.existsSync(fileName)) {
      throw `file '${fileName}' is not found.`;
    }
    if (!fs.existsSync(output)) {
      fs.mkdirSync(output, { recursive: true });
      console.log(`Created directory ${output}`);
    }

    const imgTagRegex = /(<img[^>]+src=")([^"]+)("[^>]*>)/g; // Match '<img...src="..."...>'
    const md = createMd();
    const text = fs.readFileSync(fileName, "utf8");
    let html = md.render(text);
    if (toBase64) {
      console.log("replacing images");
      html = html.replace(imgTagRegex, function (_, p1, p2, p3) {
        if (p2.startsWith("http")) {
          return _;
        }
        const imgSrc = relToAbsPath(fileName, p2);
        const imgExt = path.extname(imgSrc).slice(1);
        const file = fs.readFileSync(imgSrc).toString("base64");
        return `${p1}data:image/${imgExt};base64,${file}${p3}`;
      });
    }
    var baseName = path.basename(fileName, path.extname(fileName));
    var newFile = path.join(path.resolve(output), baseName + ".html");
    fs.writeFileSync(newFile, html);
    console.log(`Created ${newFile}`);
  } catch (error) {
    process.stderr.write(`ERROR: ${error}`);
    process.exitCode = 1;
  }
}

function createMd(): MarkdownIt {
  const hljs = require("highlight.js"); // https://highlightjs.org/

  // Actual default values
  const md = require("markdown-it")({
    html: true,
    highlight: (str: string, lang: string) => {
      // Workaround for highlight not supporting tsx: https://github.com/isagalaev/highlight.js/issues/1155
      if (
        lang &&
        ["tsx", "typescriptreact"].indexOf(lang.toLocaleLowerCase()) >= 0
      ) {
        lang = "jsx";
      }
      if (lang && hljs.getLanguage(lang)) {
        try {
          return `<div>${hljs.highlight(lang, str, true).value}</div>`;
        } catch (error) {}
      }
      return `<div>${md.utils.escapeHtml(str)}</div>`;
    },
  }).use(mdtl);
  return md;
}

function relToAbsPath(fileName: string, href: string): string {
  if (!href || href.startsWith("http") || path.isAbsolute(href)) {
    return href;
  }
  // Otherwise look relative to the markdown file
  return path.join(path.resolve(path.dirname(fileName)), href);
}

run();
