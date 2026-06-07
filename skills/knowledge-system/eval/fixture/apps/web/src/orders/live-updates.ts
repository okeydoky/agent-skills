// Live order updates for the web app.
// Updates are pulled on an interval (see the rationale card in this package's .knowledge/).

const POLL_INTERVAL_MS = 5_000;

export function startLiveOrderUpdates(orderId: string, onUpdate: (o: Order) => void) {
  const timer = setInterval(async () => {
    const res = await fetch(`/api/orders/${orderId}`);
    if (res.ok) onUpdate(await res.json());
  }, POLL_INTERVAL_MS);
  return () => clearInterval(timer);
}

export interface Order {
  id: string;
  status: "pending" | "preparing" | "ready" | "delivered";
  updatedAt: string;
}
