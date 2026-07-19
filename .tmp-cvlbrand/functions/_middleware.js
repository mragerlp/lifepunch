/**
 * Host-based 301: collaborativevalueloop.com/* -> https://cavelux.ai/$1
 * Old domain is HELD on the Pages project; this keeps the redirect live
 * without detaching it. Zone Redirect Rules preferred when Zone Edit is available.
 */
export async function onRequest(context) {
	const url = new URL(context.request.url);
	const host = url.hostname.toLowerCase();
	if (
		host === "collaborativevalueloop.com" ||
		host === "www.collaborativevalueloop.com"
	) {
		const dest = `https://cavelux.ai${url.pathname}${url.search}`;
		return Response.redirect(dest, 301);
	}
	return context.next();
}
