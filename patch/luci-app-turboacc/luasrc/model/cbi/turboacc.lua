local kernel_version = luci.sys.exec("echo -n $(uname -r)")

m = Map("turboacc")
m.title	= translate("Turbo ACC Acceleration Settings")
m.description = translate("Opensource Flow Offloading driver (Fast Path or Hardware NAT)")

m:append(Template("turboacc/turboacc_status"))

s = m:section(TypedSection, "turboacc", "")
s.addremove = false
s.anonymous = true

if nixio.fs.access("/lib/modules/" .. kernel_version .. "/xt_FLOWOFFLOAD.ko") then
sw_flow = s:option(Flag, "sw_flow", translate("Software flow offloading"))
sw_flow.default = 0
sw_flow.description = translate("Software based offloading for routing/NAT")
sw_flow:depends("sfe_flow", 0)
end

if luci.sys.call("cat /etc/openwrt_release | grep -Eq 'filogic|mt762' ") == 0 then
hw_flow = s:option(Flag, "hw_flow", translate("Hardware flow offloading"))
hw_flow.default = 0
hw_flow.description = translate("Requires hardware NAT support, implemented at least for mt762x")
hw_flow:depends("sw_flow", 1)
end

if luci.sys.call("cat /etc/openwrt_release | grep -Eq 'mediatek' ") == 0 then
if nixio.fs.access("/lib/modules/" .. kernel_version .. "/mt7915e.ko") then
hw_wed = s:option(Flag, "hw_wed", translate("MTK WED WO offloading"))
hw_wed.default = 0
hw_wed.description = translate("Requires hardware support, implemented at least for Filogic 8x0")
hw_wed:depends("hw_flow", 1)
end
end

if nixio.fs.access("/lib/modules/" .. kernel_version .. "/shortcut-fe-cm.ko")
or nixio.fs.access("/lib/modules/" .. kernel_version .. "/fast-classifier.ko")
then
sfe_flow = s:option(Flag, "sfe_flow", translate("Shortcut-FE flow offloading"))
sfe_flow.default = 0
sfe_flow.description = translate("Shortcut-FE based offloading for routing/NAT")
sfe_flow:depends("sw_flow", 0)
end

fullcone_nat = s:option(ListValue, "fullcone_nat", translate("FullCone NAT"))
fullcone_nat.default = 0
fullcone_nat:value("0", translate("Disable"))
fullcone_nat:value("1", translate("Compatible Mode"))
fullcone_nat:value("2", translate("High Performing Mode"))
fullcone_nat.description = translate("Using FullCone NAT can improve gaming performance effectively")

return m
