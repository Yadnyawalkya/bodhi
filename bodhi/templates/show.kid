<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xmlns:py="http://purl.org/kid/ns#"
    py:extends="'master.kid'">

<head>
    <meta content="text/html; charset=UTF-8" http-equiv="content-type"
            py:replace="''"/>
        <title>${update.title}</title>
</head>

<?python
from cgi import escape
from bodhi import util
from turbogears import identity

bugs = ''
cves = ''
bzlink = '<a href="https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=%d">%d</a> '
cvelink = '<a href="http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=%s">%s</a> '

## Build our reference links
for bug in update.bugs:
    bugs += bzlink % (bug.bz_id, bug.bz_id)
    if bug.title:
        bugs += '- %s<br/>' % (escape(bug.title))
bugs = bugs.replace('&', '&amp;')
for cve in update.cves:
    cves += cvelink % (cve.cve_id, cve.cve_id)

## Link to build logs
buildlogs = ''
buildinfo = ''
for build in update.builds:
    nvr = util.get_nvr(build.nvr)
    buildinfo += '<a href="http://koji.fedoraproject.org/koji/search?terms=%s&amp;type=build&amp;match=glob">%s</a><br/>' % (build.nvr, build.nvr)
    buildlogs += '<a href="http://koji.fedoraproject.org/packages/%s/%s/%s/data/logs">http://koji.fedoraproject.org/packages/%s/%s/%s/data/logs</a><br/>' % (nvr[0], nvr[1], nvr[2], nvr[0], nvr[1], nvr[2])

## Make the package name linkable in the n-v-r
title = ''
for build in update.builds:
    nvr = util.get_nvr(build.nvr)
    title += "<a href=\"" + tg.url('/%s' % nvr[0]) + "\">" + nvr[0] + "</a>-" + '-'.join(nvr[-2:]) + ", "
title = title[:-2]

release = '<a href="%s">%s</a>' % (tg.url('/%s' % update.release.name),
                                   update.release.long_name)

notes = escape(update.notes).replace('\r\n', '<br/>')
?>

<body>

    <center><table width="97%">
        <tr>
            <td><div class="show">${XML(title)}</div></td>

            <!-- update options -->
            <span py:if="util.authorized_user(update, identity)">
            <td align="right">
                [
                <span py:if="not update.pushed">
                    <span py:if="update.request == None">
                        <a href="${tg.url('/push/%s' % update.title)}">
                            Push to Testing</a> | 
                        <a href="${tg.url('/move/%s' % update.title)}">
                            Push to Stable</a> | 
                        <a href="${tg.url('/delete/%s' % update.title)}">Delete</a> | 
                    </span>
                    <a href="${tg.url('/edit/%s' % update.title)}">Edit</a>
                </span>
                <span py:if="update.pushed">
                    <a href="${tg.url('/unpush/%s' % update.title)}">Unpush</a>
                    <span py:if="update.status == 'testing'">
                        |
                        <span py:if="update.request == None">
                            <a href="${tg.url('/move/%s' % update.title)}">Mark as Stable</a> | 
                        </span>
                        <a href="${tg.url('/edit/%s' % update.title)}">Edit</a>
                    </span>
                </span>
                <span py:if="update.request != None">
                    | <a href="${tg.url('/revoke/%s' % update.title)}">Revoke request</a>
                </span>
                ]
            </td>
          </span>
        </tr>
    </table></center>

    <table class="show">
        <tr py:for="field in (
            ['Release',       XML(release)],
            ['Update ID',     update.update_id],
            ['Status',        update.status],
            ['Type',          update.type],
            ['Bugs',          (bugs) and XML(bugs) or ''],
            ['CVEs',          (cves) and XML(cves) or ''],
            ['Embargo',       update.type == 'security' and update.embargo or ''],
            ['Requested',     update.request],
            ['Pushed',        update.pushed],
            ['Date Pushed',   update.date_pushed],
            ['Submitter',     update.submitter],
            ['Submitted',     update.date_submitted],
            ['Modified',      update.date_modified],
            ['Build Info',    XML(buildinfo)],
            ['Build Logs',    XML(buildlogs)]
        )">
                <span py:if="field[1] != None and field[1] != ''">
                    <td class="title"><b>${field[0]}:</b></td>
                    <td class="value">${field[1]}</td>
                </span>
        </tr>
        <tr>
            <span py:if="update.notes">
                <td class="title"><b>Notes:</b></td>
                <td class="value">${XML(notes)}</td>
            </span>
        </tr>
        <tr>
            <span py:if="update.comments">
                <td class="title"><b>Comments:</b></td>
                <td class="value">
                    <div py:for="comment in update.comments">
                        <b>${comment.author}</b> - ${comment.timestamp}<br/>
                        <div py:replace="comment.text">Comment</div>
                    </div>
                </td>
            </span>
        </tr>
        <tr>
            <td class="title"></td>
            <td class="value">
                ${comment_form.display(value=values)}
            </td>
        </tr>
        <tr><td class="title"></td></tr>
    </table>

</body>
</html>
