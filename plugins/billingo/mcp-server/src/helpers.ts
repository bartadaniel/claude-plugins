export function toolResult(data: unknown) {
  return { content: [{ type: 'text' as const, text: JSON.stringify(data, null, 2) }] };
}

export async function handleError(fn: () => Promise<unknown>) {
  try {
    return toolResult(await fn());
  } catch (err: unknown) {
    let message = 'Unknown error';
    if (err instanceof Error) {
      // Axios errors may contain HTTP details (URLs, status codes) in err.message.
      // Extract only the response body message to avoid leaking request config.
      const axiosErr = err as { response?: { status?: number; data?: { error?: { message?: string } } } };
      if (axiosErr.response) {
        const status = axiosErr.response.status;
        const apiMessage = axiosErr.response.data?.error?.message;
        message = apiMessage ? `Billingo API error ${status}: ${apiMessage}` : `Billingo API error ${status}`;
      } else {
        message = err.message;
      }
    }
    return { content: [{ type: 'text' as const, text: `Error: ${message}` }], isError: true as const };
  }
}
