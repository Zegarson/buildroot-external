include $(sort $(wildcard $(BR2_EXTERNAL_ZEGARSON_PATH)/package/*/*.mk))

.PHONY: target-add-ssh-authorized-keys
target-add-ssh-authorized-keys:
	$(Q)if which ssh-add >/dev/null 2>&1; then \
		$(call MESSAGE,"Add SSH authorized keys"); \
		install -d -m750 $(TARGET_DIR)/root/.ssh; \
		ssh-add -L > $(TARGET_DIR)/root/.ssh/authorized_keys; \
	fi

.PHONY: rm-build
rm-build:
	rm -rf $(BUILD_DIR)/*/*

.PHONY: rm-target
rm-target:
	rm -rf $(BASE_TARGET_DIR)
	rm -rf $(BUILD_DIR)/*/.stamp_target_installed