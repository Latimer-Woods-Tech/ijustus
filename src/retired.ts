/** Retirement marker. Keep the existing hostnames from serving the old app. */
export default {
  fetch(): Response {
    return new Response('iJustus has been retired.\n', {
      status: 410,
      headers: {
        'content-type': 'text/plain; charset=utf-8',
        'cache-control': 'no-store',
        'x-service-status': 'retired',
      },
    });
  },
} satisfies ExportedHandler;
