# Interviewer Bot

Practice for a real job interview before the real thing. Interviewer Bot
asks you interview questions, listens to your answers, and gives you a
private report at the end. It runs right inside Claude — there is no extra
app to install.

## What you need

Before you start, have these ready:

1. **The job description.** Copy and paste it, or upload the file. (Required)
2. **Your resume.** Copy and paste it, or upload a PDF or Word file. (Required)
3. **A cover letter.** Only if you wrote one. (Optional)
4. **Info about the company.** Their "About Us" page, a Glassdoor review,
   anything like that. (Optional — the interview will just sound more
   general without it.)

## How to start

Type:

```
/interview
```

Or just say something like "Can you run a mock interview for me?" Claude
will ask for your job description and resume if you have not shared them
yet.

## What happens next

1. **Claude reads your files** and asks a couple of quick setup questions,
   like how hard the questions should be and how many questions you want.
   You can just say "defaults" to skip all of that and start right away.
2. **The interview begins.** Claude plays the part of a real interviewer at
   that company. It asks one question at a time and listens closely to
   your answer.
3. **If your answer is a little thin, Claude will ask a follow-up** — just
   like a real interviewer would. This is normal. It means Claude is
   paying attention.
4. **Near the end, you get to ask questions too**, like you would in a real
   interview.

Claude stays "in character" the whole time. It will not tell you how you
are doing partway through — that is on purpose. Real interviewers do not
grade you out loud either.

## Ending early

Type `/exit` at any point and Claude will stop the interview and skip
straight to your report.

## Your report

When the interview ends (on its own, or because you typed `/exit`), Claude
writes you a report called an "Interview Performance Review" and saves it
as a file you can keep. It includes:

- **An overall grade** — Strong Hire, Lean Hire, or No Hire — with a short
  explanation
- **A breakdown** of how you did in four areas: how clearly you spoke, how
  well your experience matched the job, how complete your stories were,
  and how well you seemed to fit the company
- **A few of your real answers**, rewritten to be stronger, with an
  explanation of why the new version works better
- **Your top 3 things to work on** before the real interview

The first time Claude saves a report, it will ask you to connect a folder
(sometimes called a "working folder"), so your reports stick around after
the chat ends.

## Try it with sample inputs

Want to test it out first? Paste this pretend job description and resume.

**Sample job description:**

```
Customer Support Specialist — Acme Software
We're looking for someone to answer customer emails and chat messages,
solve simple technical problems, and hand off harder issues to
engineering. 2+ years in a customer-facing role preferred. Must be a
clear writer and comfortable using a help-desk tool like Zendesk.
```

**Sample resume:**

```
Jordan Lee
2 years as a retail sales associate at a mid-size electronics store.
Handled customer questions in person and by phone. Trained two new
hires. Comfortable with basic computer systems; no formal help-desk
software experience.
```

Paste both in, say "defaults" when Claude asks about setup, and answer a
few questions to see how it works.

## Changelog

- **0.1.0** — first version: reads your resume and job description, lets
  you adjust the difficulty and number of questions, interviews you in
  three steps with natural follow-up questions, matches its style to five
  different company cultures, and ends with a saved, private performance
  review.

*To update an installed plugin, see [How do I get the latest version?](../../docs/GETTING-STARTED.md#troubleshooting--faq)*
