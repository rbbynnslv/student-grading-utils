#!/usr/bin/env node

const process = require('process');
const fs = require('fs');
const path = require('path');
const github = require('@octokit/rest')();
const { promisify } = require('util');

const writeFileAsync = promisify(fs.writeFile);

const argv = require('yargs')
  .option('output', {
    alias: 'o',
    default: '.',
    describe: 'the output directory for downloaded repositories',
    type: 'string',
  })
  .option('repo', {
    alias: 'r',
    describe: 'github repository url',
    demandOption: true,
    type: 'string',
  })
  .option('branch', {
    alias: 'b',
    describe: 'The branch name that should be downloaded from the fork',
    demandOption: true,
    type: 'string',
  }).argv;

const config = {
  outputDir: argv.output,
  repo: argv.repo,
  branch: argv.branch,
};

async function downloadRepoArchives(outputDir, archConfigs) {
  archConfigs.forEach(async config => {
    const outputPath = path.resolve(
      outputDir,
      `${config.owner}_${config.repo}.tar.gz`
    );
    try {
      return repoArchive = await github.repos.getArchiveLink(config)
    } catch (e) {
      console.error(`Repository of ${config.owner} cannot be found!`)
    } finally {
      if (typeof repoArchive !== 'undefined') {
        await writeFileAsync(outputPath, repoArchive.data);
        console.log(outputPath)
      }
    }
  });
}

function parseRepoUrl(url) {
  const path = new URL(url).pathname.split('/');
  return {
    owner: path[1],
    name: path[2],
  };
}

(async function ({ repo, branch, outputDir }) {
  console.error(
    'Downloaded repositories will be placed in: ',
    path.resolve(outputDir)
  );

  try {
    const repoData = parseRepoUrl(repo);

    const finalRepoPulls = await github.pulls.list({
      owner: repoData.owner,
      repo: repoData.name,
      state: 'open',
      sort: 'created',
      per_page: 100,
    });

    const prRepos = finalRepoPulls.data.map(pr => {
      return {
        owner: pr.user.login,
        repo: pr.head.repo.name,
        archive_format: 'tarball',
        ref: branch,
      };
    });

    let records = fs.readFileSync('/home/webdev/Desktop/student-grading-utils/students.txt', 'utf8'); //Url is static
    let hasStudents = parseInt(records.length) > 0 ? true : false;
    let studentsLength = parseInt(records.length);

    if (hasStudents) {
      var students = records.toString().split("\n");
      for (i = 0; i < studentsLength; i++) {
        var result = prRepos.filter(obj => obj.owner === students[i]);
        await downloadRepoArchives(outputDir, result);
      }
    } else {
      await downloadRepoArchives(outputDir, prRepos);
    }
  } catch (e) {
    console.error(e);
    process.exitCode = 1;
  }
})(config);